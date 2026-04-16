//
//  AuthRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Entity

import Service
import ThirdPartys
import Dependencies
import Moya
import LogMacro

import ThirdPartys


final public class AuthRepositoryImpl: AuthInterface, @unchecked Sendable {
  @Dependency(\.keychainManager) private var keychainManager
  private let provider: MoyaProvider<AuthService>
  private let authProvider: MoyaProvider<AuthService>

  public init(
    provider: MoyaProvider<AuthService> = MoyaProvider<AuthService>.default,
    authProvider: MoyaProvider<AuthService> = MoyaProvider<AuthService>.authorized
  ) {
    self.provider = provider
    self.authProvider = authProvider
  }

  // MARK: - 로그인 API
  public func login(
    provider socialProvider: SocialType,
    token: String
  ) async throws -> LoginEntity {
    let dto: LoginResponseDTO = try await provider.request(
      .login(body: OAuthLoginRequest(provider: socialProvider.description, token: token))
     )
    return dto.toDomain()
  }


  // MARK: - 토큰 재발급
  public func refresh() async throws -> AuthTokens {
    let refreshToken  = keychainManager.refreshToken() ?? ""

    do {
      // Use non-authorized provider to avoid interceptor recursion on refresh.
      let dto: TokenDTO = try await provider.request(.refresh(refreshToken: refreshToken))
      let refreshData = dto.toDomain()

      // ✅ TokenRefresher에서 keychain 저장과 credential 업데이트를 담당하므로 중복 제거
      return refreshData
    } catch {
      #logDebug("🔍 [AuthRepositoryImpl] Refresh failed: \(error)")

      // 401 에러 감지 및 처리는 AuthInterceptor에서 처리하므로 여기서는 단순히 에러 전달
      // AuthInterceptor가 더 정확하고 포괄적인 401 에러 감지를 수행
      let errorString = String(describing: error)
      if errorString.contains("statusCodeError(401)") {
        #logDebug("🚪 [AuthRepositoryImpl] statusCodeError(401) detected - AuthInterceptor will handle logout")
        throw AuthError.refreshTokenExpired
      }

      // MoyaError 401 체크
      if let moyaError = error as? MoyaError {
        switch moyaError {
        case .statusCode(let response) where response.statusCode == 401:
          #logDebug("🚪 [AuthRepositoryImpl] MoyaError statusCode 401 detected - AuthInterceptor will handle logout")
          throw AuthError.refreshTokenExpired
        case .underlying(_, let response) where response?.statusCode == 401:
          #logDebug("🚪 [AuthRepositoryImpl] MoyaError underlying 401 detected - AuthInterceptor will handle logout")
          throw AuthError.refreshTokenExpired
        default:
          break
        }
      }

      // 에러 메시지에서 401 키워드 체크
      let errorDesc = error.localizedDescription.lowercased()
      if errorDesc.contains("401") || errorDesc.contains("유효하지 않은 토큰") {
        #logDebug("🚪 [AuthRepositoryImpl] Error description contains 401/invalid token - AuthInterceptor will handle logout")
        throw AuthError.refreshTokenExpired
      }

      throw error
    }
  }

  // MARK: - 로그아웃
  public func logout() async throws -> AuthExitEntity {
    let response = try await authProvider.requestResponse(.logout)
    let decoder = JSONDecoder()

    if (200...299).contains(response.statusCode) {
      keychainManager.clear()
      if response.data.isEmpty {
        return AuthExitEntity()
      }
      if let successDTO = try? decoder.decode(LogOutDTO.self, from: response.data) {
        return successDTO.toDomain()
      }
      return AuthExitEntity()
    }

    if let errorDTO = try? decoder.decode(LogOutDTO.self, from: response.data) {
      return errorDTO.toDomain()
    }
    
    let errorMessage = String(data: response.data, encoding: .utf8)
    return AuthExitEntity(message: errorMessage)
  }

  // MARK: - 계정 삭제
  public func withDraw(token: String) async throws -> WithdrawEntity {
    let response = try await provider.requestResponse(.withdraw(token: token))
    let decoder = JSONDecoder()

    if (200...299).contains(response.statusCode) {
      if response.data.isEmpty {
        return WithdrawEntity(isSuccess: true)
      }
      if let successDTO = try? decoder.decode(WithdrawDTO.self, from: response.data) {
        return successDTO.toDomain(isSuccess: true)
      }
      return WithdrawEntity(isSuccess: true)
    }

    if let errorDTO = try? decoder.decode(WithdrawDTO.self, from: response.data) {
      return errorDTO.toDomain(isSuccess: false)
    }
    return WithdrawEntity(
      isSuccess: false,
      message: String(data: response.data, encoding: .utf8)
    )
  }

  // MARK: - 세션 Credential 업데이트
  public func updateSessionCredential(with tokens: AuthTokens) {
    AuthSessionManager.shared.updateCredential(with: tokens)
  }

}
