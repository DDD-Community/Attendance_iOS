//
//  UnifiedOAuthUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation
import Dependencies
import AuthenticationServices
@preconcurrency import Entity
import DomainInterface
import Sharing
import LogMacro

/// 통합 OAuth UseCase - 로그인/회원가입 플로우를 하나로 통합
public struct UnifiedOAuthUseCase {
  @Dependency(\.authRepository) private var authRepository: AuthInterface
  @Dependency(\.appleOAuthProvider) private var appleProvider: AppleOAuthProviderInterface
  @Dependency(\.googleOAuthProvider) private var googleProvider: GoogleOAuthProviderInterface
  @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
  public init() {}
}

// MARK: - Public Interface

public extension UnifiedOAuthUseCase {

  /// 통합 소셜 로그인 처리
  func socialLogin(
    with socialType: SocialType,
    appleCredential: ASAuthorizationAppleIDCredential? = nil,
    nonce: String? = nil,
    googleToken: String? = nil
  ) async throws -> LoginEntity {
    switch socialType {
    case .apple:
      guard let credential = appleCredential, let nonce = nonce else {
        throw AuthError.invalidCredential("Apple 로그인에 필요한 credential 또는 nonce가 없습니다")
      }
      return try await appleLogin(credential: credential, nonce: nonce)
    case .google:
      guard let token = googleToken else {
        throw AuthError.invalidCredential("Google 로그인에 필요한 token이 없습니다")
      }
      return try await googleLogin(token: token)
    }
  }

  /// Apple 로그인 처리
  func appleLogin(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> LoginEntity {
    let payload = try await appleProvider.signInWithCredential(
      credential: credential,
      nonce: nonce
    )
    Log.debug("apple authcode", payload.authorizationCode)
    self.$userSession.withLock { $0.token = payload.idToken }
    return try await authRepository.login(
      provider: .apple,
      token: payload.authorizationCode ?? ""
    )
  }

  /// Google 로그인 처리
  func googleLogin(
    token: String
  ) async throws -> LoginEntity {
    let processedToken = try await googleProvider.signInWithToken(token: token)
    self.$userSession.withLock { $0.token = processedToken }
    return try await authRepository.login(
      provider: .google,
      token: processedToken
    )
  }

  /// OAuth 플로우 처리 (TCA용)
  func processOAuthFlow(
    with socialType: SocialType,
    appleCredential: ASAuthorizationAppleIDCredential? = nil,
    nonce: String? = nil,
    googleToken: String? = nil
  ) async -> Result<LoginEntity, AuthError> {
    do {
      let result = try await socialLogin(
        with: socialType,
        appleCredential: appleCredential,
        nonce: nonce,
        googleToken: googleToken
      )
      return .success(result)
    } catch let error as AuthError {
      return .failure(error)
    } catch {
      return .failure(.unknownError(error.localizedDescription))
    }
  }
}

// MARK: - Dependencies Registration

extension UnifiedOAuthUseCase: DependencyKey {
  public static let liveValue = UnifiedOAuthUseCase()
  public static let testValue = UnifiedOAuthUseCase()
  public static let previewValue = UnifiedOAuthUseCase()
}

extension DependencyValues {
  public var unifiedOAuthUseCase: UnifiedOAuthUseCase {
    get { self[UnifiedOAuthUseCase.self] }
    set { self[UnifiedOAuthUseCase.self] = newValue }
  }
}
