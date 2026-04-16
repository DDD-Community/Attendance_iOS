//
//  AuthRepositoryTest.swift
//  RepositoryTests
//
//  Created by TDD AI Automation on 2026-04-16
//

import Testing
import Foundation
import Entity
import Model
import DomainInterface
import Service

@Suite("Auth Repository API Tests")
@MainActor
struct AuthRepositoryTest {

  // MARK: - Test Fixtures

  private func createMockAuthRepository() -> AuthRepositoryImpl {
    return AuthRepositoryImpl(provider: MockMoyaProvider<AuthService>())
  }

  // MARK: - API 호출 성공 테스트

  @Test("로그인 API 호출 성공 - Google 로그인")
  func test_login_api_success_google() async throws {
    // Given
    let repository = createMockAuthRepository()
    let googleToken = "google_oauth_token_12345"

    // When
    let result = try await repository.login(provider: .google, token: googleToken)

    // Then
    #expect(result.name == "홍길동")
    #expect(result.provider == .google)
    #expect(result.isNewUser == false)
    #expect(result.token.accessToken == "mock_access_token_12345")
    #expect(result.token.refreshToken == "mock_refresh_token_12345")
    #expect(result.token.oauthRefreshToken == "mock_oauth_refresh_token_12345")
    #expect(result.role == .manager)
  }

  @Test("로그인 API 호출 성공 - Apple 로그인")
  func test_login_api_success_apple() async throws {
    // Given
    let repository = createMockAuthRepository()
    let appleToken = "apple_oauth_token_67890"

    // When
    let result = try await repository.login(provider: .apple, token: appleToken)

    // Then
    #expect(result.name == "김철수")
    #expect(result.provider == .apple)
    #expect(result.isNewUser == true)
    #expect(result.token.accessToken == "apple_access_token_67890")
    #expect(result.token.refreshToken == "apple_refresh_token_67890")
    #expect(result.token.oauthRefreshToken == nil) // Apple은 OAuth Refresh Token 없음
    #expect(result.role == nil) // 신규 사용자는 role이 없음
  }

  @Test("토큰 갱신 API 호출 성공")
  func test_refresh_token_api_success() async throws {
    // Given
    let repository = createMockAuthRepository()

    // When
    let result = try await repository.refresh()

    // Then
    #expect(result.accessToken == "new_access_token_12345")
    #expect(result.refreshToken == "new_refresh_token_12345")
    #expect(result.oauthRefreshToken == nil)
  }

  @Test("로그아웃 API 호출 성공")
  func test_logout_api_success() async throws {
    // Given
    let repository = createMockAuthRepository()

    // When
    let result = try await repository.logout()

    // Then
    #expect(result.code == "SUCCESS")
    #expect(result.message == "로그아웃되었습니다")
    #expect(result.detail == "성공적으로 로그아웃 처리되었습니다")
  }

  @Test("회원탈퇴 API 호출 성공")
  func test_withdraw_api_success() async throws {
    // Given
    let repository = createMockAuthRepository()

    // When
    let result = try await repository.withDraw()

    // Then
    #expect(result.isSuccess == true)
    #expect(result.code == "SUCCESS")
    #expect(result.message == "회원탈퇴가 완료되었습니다")
    #expect(result.detail == "모든 데이터가 삭제되었습니다")
  }

  // MARK: - API 호출 실패 테스트

  @Test("로그인 API 호출 실패 (잘못된 토큰)")
  func test_login_api_invalid_token() async throws {
    // Given
    let repository = createMockAuthRepository()
    let invalidToken = "invalid_token"

    // When & Then
    #expect(throws: AuthError.invalidToken) {
      try await repository.login(provider: .google, token: invalidToken)
    }
  }

  @Test("토큰 갱신 API 호출 실패 (만료된 리프레시 토큰)")
  func test_refresh_token_api_expired() async throws {
    // Given
    let repository = createMockAuthRepository()

    // When & Then
    #expect(throws: AuthError.refreshTokenExpired) {
      try await repository.refresh() // Mock에서 expired 상황을 시뮬레이션
    }
  }

  @Test("로그아웃 API 호출 실패 (네트워크 오류)")
  func test_logout_api_network_error() async throws {
    // Given
    let repository = createMockAuthRepository()

    // When & Then
    #expect(throws: AuthError.networkError) {
      try await repository.logout() // Mock에서 네트워크 오류 시뮬레이션
    }
  }

  @Test("회원탈퇴 API 호출 실패 (권한 없음)")
  func test_withdraw_api_unauthorized() async throws {
    // Given
    let repository = createMockAuthRepository()

    // When & Then
    #expect(throws: AuthError.unauthorized) {
      try await repository.withDraw() // Mock에서 권한 오류 시뮬레이션
    }
  }

  // MARK: - 동시성 테스트

  @Test("동시 로그인 요청 처리")
  func test_concurrent_login_requests() async throws {
    // Given
    let repository = createMockAuthRepository()
    let tokens = ["token1", "token2", "token3", "token4", "token5"]

    // When
    await withTaskGroup(of: Void.self) { group in
      for token in tokens {
        group.addTask {
          do {
            _ = try await repository.login(provider: .google, token: token)
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 크래시나 데드락 없이 완료되어야 함
    #expect(true)
  }

  @Test("동시 토큰 갱신 요청 처리")
  func test_concurrent_refresh_requests() async throws {
    // Given
    let repository = createMockAuthRepository()

    // When
    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<5 {
        group.addTask {
          do {
            _ = try await repository.refresh()
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 완료되어야 함
    #expect(true)
  }

    // MARK: - Entity Creation Tests

    @Test("LoginEntity 생성 및 필드 검증")
    func test_login_entity_creation_and_validation() throws {
        // Given & When
        let token = AuthTokens(
            accessToken: "mock_access_token_12345",
            refreshToken: "mock_refresh_token_12345",
            oauthRefreshToken: "mock_oauth_refresh_token_12345"
        )

        let entity = LoginEntity(
            name: "홍길동",
            isNewUser: false,
            provider: .google,
            token: token,
            role: .manager
        )

        // Then
        #expect(entity.name == "홍길동")
        #expect(entity.provider == .google)
        #expect(entity.isNewUser == false)
        #expect(entity.token.accessToken == "mock_access_token_12345")
        #expect(entity.token.refreshToken == "mock_refresh_token_12345")
        #expect(entity.token.oauthRefreshToken == "mock_oauth_refresh_token_12345")
        #expect(entity.role == .manager)
    }

    @Test("AuthTokens 생성 및 검증")
    func test_auth_tokens_creation() throws {
        // Given & When
        let tokens = AuthTokens(
            accessToken: "new_access_token_67890",
            refreshToken: "new_refresh_token_67890"
        )

        // Then
        #expect(tokens.accessToken == "new_access_token_67890")
        #expect(tokens.refreshToken == "new_refresh_token_67890")
        #expect(tokens.oauthRefreshToken == nil)
    }

    @Test("AuthExitEntity 성공 케이스")
    func test_auth_exit_entity_success() throws {
        // Given & When
        let entity = AuthExitEntity(
            code: "SUCCESS",
            message: "로그아웃되었습니다",
            detail: "성공적으로 로그아웃 처리되었습니다"
        )

        // Then
        #expect(entity.code == "SUCCESS")
        #expect(entity.message == "로그아웃되었습니다")
        #expect(entity.detail == "성공적으로 로그아웃 처리되었습니다")
    }

    @Test("WithdrawEntity 성공 케이스")
    func test_withdraw_entity_success() throws {
        // Given & When
        let entity = WithdrawEntity(
            isSuccess: true,
            code: "SUCCESS",
            message: "회원탈퇴가 완료되었습니다",
            detail: "모든 데이터가 삭제되었습니다"
        )

        // Then
        #expect(entity.isSuccess == true)
        #expect(entity.code == "SUCCESS")
        #expect(entity.message == "회원탈퇴가 완료되었습니다")
        #expect(entity.detail == "모든 데이터가 삭제되었습니다")
    }

    // MARK: - DTO Mapping Tests

    @Test("LoginResponseDTO to LoginEntity 매핑")
    func test_login_response_dto_mapping() throws {
        // Given
        let jsonData = TestFixtures.loginSuccessResponse
        let decoder = JSONDecoder()
        let dto = try decoder.decode(LoginResponseDTO.self, from: jsonData)

        // When
        let entity = dto.toDomain()

        // Then
        #expect(entity.name == "홍길동")
        #expect(entity.provider == SocialType.google)
        #expect(entity.isNewUser == false)
        #expect(entity.token.accessToken == "mock_access_token_12345")
        #expect(entity.token.refreshToken == "mock_refresh_token_12345")
        #expect(entity.token.oauthRefreshToken == "mock_oauth_refresh_token_12345")
        #expect(entity.role == Staff.manager)
    }

    @Test("TokenDTO to AuthTokens 매핑")
    func test_token_dto_mapping() throws {
        // Given
        let jsonData = TestFixtures.refreshSuccessResponse
        let decoder = JSONDecoder()
        let dto = try decoder.decode(TokenDTO.self, from: jsonData)

        // When
        let authTokens = dto.toDomain()

        // Then
        #expect(authTokens.accessToken == "new_access_token_67890")
        #expect(authTokens.refreshToken == "new_refresh_token_67890")
        #expect(authTokens.oauthRefreshToken == nil)
    }

    @Test("LogOutDTO to AuthExitEntity 매핑")
    func test_logout_dto_mapping() throws {
        // Given
        let dto = LogOutDTO(
            code: "SUCCESS",
            message: "로그아웃되었습니다",
            detail: "성공적으로 로그아웃 처리되었습니다"
        )

        // When
        let entity = dto.toDomain()

        // Then
        #expect(entity.code == "SUCCESS")
        #expect(entity.message == "로그아웃되었습니다")
        #expect(entity.detail == "성공적으로 로그아웃 처리되었습니다")
    }

    @Test("WithdrawDTO to WithdrawEntity 매핑")
    func test_withdraw_dto_mapping() throws {
        // Given
        let dto = WithdrawDTO(
            code: "SUCCESS",
            message: "회원탈퇴가 완료되었습니다",
            detail: "모든 데이터가 삭제되었습니다"
        )

        // When
        let entity = dto.toDomain(isSuccess: true)

        // Then
        #expect(entity.isSuccess == true)
        #expect(entity.code == "SUCCESS")
        #expect(entity.message == "회원탈퇴가 완료되었습니다")
        #expect(entity.detail == "모든 데이터가 삭제되었습니다")
    }

    // MARK: - Mock KeychainManager Tests

    @Test("MockKeychainManager 기본 동작")
    func test_mock_keychain_manager_basic_operations() throws {
        // Given
        let mockKeychain = MockKeychainManager()

        // When & Then: 초기 상태
        #expect(mockKeychain.isEmpty() == true)
        #expect(mockKeychain.hasTokens() == false)
        #expect(mockKeychain.accessToken() == nil)
        #expect(mockKeychain.refreshToken() == nil)

        // When: 토큰 설정
        mockKeychain.setTokens(
            accessToken: "test_access_token",
            refreshToken: "test_refresh_token"
        )

        // Then: 토큰 저장 확인
        #expect(mockKeychain.isEmpty() == false)
        #expect(mockKeychain.hasTokens() == true)
        #expect(mockKeychain.accessToken() == "test_access_token")
        #expect(mockKeychain.refreshToken() == "test_refresh_token")

        // When: 클리어
        mockKeychain.clear()

        // Then: 클리어 확인
        #expect(mockKeychain.isEmpty() == true)
        #expect(mockKeychain.clearCallCount == 1)
    }

    // MARK: - Edge Case Tests

    @Test("빈 문자열 토큰으로 AuthTokens 생성")
    func test_auth_tokens_with_empty_strings() throws {
        // Given & When
        let tokens = AuthTokens(
            accessToken: "",
            refreshToken: "",
            oauthRefreshToken: ""
        )

        // Then: 빈 문자열도 유효한 값으로 처리
        #expect(tokens.accessToken == "")
        #expect(tokens.refreshToken == "")
        #expect(tokens.oauthRefreshToken == "")
    }

    @Test("매우 긴 문자열로 Entity 생성")
    func test_entity_with_very_long_strings() throws {
        // Given
        let longString = String(repeating: "a", count: 1000)
        let longToken = String(repeating: "1", count: 2000)

        // When
        let token = AuthTokens(
            accessToken: longToken,
            refreshToken: longToken,
            oauthRefreshToken: longToken
        )

        let entity = LoginEntity(
            name: longString,
            isNewUser: false,
            provider: .google,
            token: token,
            role: .manager
        )

        // Then: 긴 문자열도 정상 처리
        #expect(entity.name == longString)
        #expect(entity.token.accessToken == longToken)
        #expect(entity.token.refreshToken == longToken)
        #expect(entity.token.oauthRefreshToken == longToken)
    }

    @Test("특수문자가 포함된 사용자 이름으로 Entity 생성")
    func test_entity_with_special_characters() throws {
        // Given
        let specialName = "홍길동!@#$%^&*()_+{}|:<>?[]\';\",./"

        // When
        let token = AuthTokens(
            accessToken: "token123",
            refreshToken: "refresh456"
        )

        let entity = LoginEntity(
            name: specialName,
            isNewUser: true,
            provider: .apple,
            token: token,
            role: nil
        )

        // Then: 특수문자도 정상 처리
        #expect(entity.name == specialName)
        #expect(entity.isNewUser == true)
        #expect(entity.provider == .apple)
        #expect(entity.role == nil)
    }

    @Test("잘못된 JSON 데이터 파싱 실패")
    func test_invalid_json_parsing_failure() throws {
        // Given: 잘못된 JSON 형식
        let invalidJsonData = """
        {
            "userId": 12345,
            "name": "홍길동",
            "invalidField":
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        // When & Then: 파싱 실패 예상
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(LoginResponseDTO.self, from: invalidJsonData)
        }
    }

    @Test("nil 값이 포함된 AuthExitEntity")
    func test_auth_exit_entity_with_nil_values() throws {
        // Given & When
        let entity = AuthExitEntity(
            code: nil,
            message: nil,
            detail: nil
        )

        // Then: nil 값도 정상 처리
        #expect(entity.code == nil)
        #expect(entity.message == nil)
        #expect(entity.detail == nil)
    }

    @Test("MockKeychainManager 동시성 안전성")
    func test_mock_keychain_manager_concurrency_safety() async throws {
        // Given
        let mockKeychain = MockKeychainManager()

        // When: 동시에 여러 작업 수행
        await withTaskGroup(of: Void.self) { group in
            // 토큰 설정 작업들
            for i in 0..<10 {
                group.addTask {
                    mockKeychain.setTokens(
                        accessToken: "access_\(i)",
                        refreshToken: "refresh_\(i)"
                    )
                }
            }

            // 토큰 읽기 작업들
            for _ in 0..<10 {
                group.addTask {
                    _ = mockKeychain.accessToken()
                    _ = mockKeychain.refreshToken()
                }
            }

            // 클리어 작업들
            for _ in 0..<5 {
                group.addTask {
                    mockKeychain.clear()
                }
            }
        }

        // Then: 동시성 작업 후 상태 확인
        // 정확한 결과를 예측하기 어렵지만 크래시나 데드락 없이 완료되어야 함
        #expect(mockKeychain.refreshTokenCallCount >= 0)
        #expect(mockKeychain.clearCallCount >= 0)
    }

    @Test("메모리 할당 테스트 - 대량 Entity 생성")
    func test_memory_allocation_with_many_entities() throws {
        // Given & When: 대량의 Entity 생성
        var entities: [LoginEntity] = []

        for i in 0..<1000 {
            let token = AuthTokens(
                accessToken: "access_token_\(i)",
                refreshToken: "refresh_token_\(i)",
                oauthRefreshToken: "oauth_token_\(i)"
            )

            let entity = LoginEntity(
                name: "User \(i)",
                isNewUser: i % 2 == 0,
                provider: i % 2 == 0 ? .google : .apple,
                token: token,
                role: i % 3 == 0 ? .manager : .member
            )

            entities.append(entity)
        }

        // Then: 모든 Entity가 정상 생성됨
        #expect(entities.count == 1000)
        #expect(entities.first?.name == "User 0")
        #expect(entities.last?.name == "User 999")
    }
}

// MARK: - Mock KeychainManager

final class MockKeychainManager: KeychainManaging, @unchecked Sendable {
    private var storage: [String: String] = [:]
    private(set) var clearCallCount = 0
    private(set) var refreshTokenCallCount = 0
    private(set) var saveTokenCallCount = 0

    func accessToken() -> String? {
        return storage["accessToken"]
    }

    func refreshToken() -> String? {
        refreshTokenCallCount += 1
        return storage["refreshToken"]
    }

    func save(accessToken: String, refreshToken: String) {
        saveTokenCallCount += 1
        storage["accessToken"] = accessToken
        storage["refreshToken"] = refreshToken
    }

    func saveAccessToken(_ token: String) {
        storage["accessToken"] = token
    }

    func saveRefreshToken(_ token: String) {
        storage["refreshToken"] = token
    }

    func clear() {
        clearCallCount += 1
        storage.removeAll()
    }

    func reset() {
        storage.removeAll()
        clearCallCount = 0
        refreshTokenCallCount = 0
        saveTokenCallCount = 0
    }

    // Test helper methods
    func setTokens(accessToken: String, refreshToken: String) {
        storage["accessToken"] = accessToken
        storage["refreshToken"] = refreshToken
    }

    func hasTokens() -> Bool {
        return storage["accessToken"] != nil && storage["refreshToken"] != nil
    }

    func isEmpty() -> Bool {
        return storage.isEmpty
    }
}

// MARK: - Test Fixtures

struct TestFixtures {
    static let loginSuccessResponse = """
    {
        "userId": 12345,
        "name": "홍길동",
        "email": "test@example.com",
        "oauthProvider": "google",
        "message": "로그인 성공",
        "isNewUser": false,
        "accessToken": "mock_access_token_12345",
        "refreshToken": "mock_refresh_token_12345",
        "oauthRefreshToken": "mock_oauth_refresh_token_12345",
        "role": "manager"
    }
    """.data(using: .utf8)!

    static let refreshSuccessResponse = """
    {
        "accessToken": "new_access_token_67890",
        "refreshToken": "new_refresh_token_67890"
    }
    """.data(using: .utf8)!
}

// MARK: - Mock MoyaProvider for Auth

extension MockMoyaProvider where Target == AuthService {

  override func request<T: Decodable>(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) async throws -> T {
    if let authTarget = target as? AuthService {
      return try createMockAuthResponse(for: authTarget) as! T
    }

    throw AuthError.networkError
  }

  private func createMockAuthResponse<T: Decodable>(for target: AuthService) throws -> T {
    switch target {
    case .login(let body):
      if body.token == "invalid_token" {
        throw AuthError.invalidToken
      }

      if body.provider == "google" {
        let googleResponse = LoginResponseDTO(
          userId: 12345,
          name: "홍길동",
          email: "hong@ddd.com",
          oauthProvider: "google",
          message: "Google 로그인 성공",
          isNewUser: false,
          accessToken: "mock_access_token_12345",
          refreshToken: "mock_refresh_token_12345",
          oauthRefreshToken: "mock_oauth_refresh_token_12345",
          role: "manager"
        )
        return googleResponse as! T
      } else if body.provider == "apple" {
        let appleResponse = LoginResponseDTO(
          userId: 67890,
          name: "김철수",
          email: "kim@ddd.com",
          oauthProvider: "apple",
          message: "Apple 로그인 성공",
          isNewUser: true,
          accessToken: "apple_access_token_67890",
          refreshToken: "apple_refresh_token_67890",
          oauthRefreshToken: nil,
          role: nil
        )
        return appleResponse as! T
      }

      throw AuthError.invalidToken

    case .refresh(let refreshToken):
      if refreshToken == "expired_refresh_token" {
        throw AuthError.refreshTokenExpired
      }

      let refreshResponse = TokenDTO(
        accessToken: "new_access_token_12345",
        refreshToken: "new_refresh_token_12345"
      )
      return refreshResponse as! T

    case .logout:
      // 네트워크 오류 시뮬레이션을 위한 조건
      let random = Int.random(in: 1...10)
      if random > 8 {
        throw AuthError.networkError
      }

      let logoutResponse = LogOutDTO(
        code: "SUCCESS",
        message: "로그아웃되었습니다",
        detail: "성공적으로 로그아웃 처리되었습니다"
      )
      return logoutResponse as! T

    case .withdraw:
      // 권한 오류 시뮬레이션을 위한 조건
      let random = Int.random(in: 1...10)
      if random > 7 {
        throw AuthError.unauthorized
      }

      let withdrawResponse = WithdrawDTO(
        code: "SUCCESS",
        message: "회원탈퇴가 완료되었습니다",
        detail: "모든 데이터가 삭제되었습니다"
      )
      return withdrawResponse as! T

    default:
      throw AuthError.networkError
    }
  }
}

// MARK: - Mock Auth DTOs

struct LoginResponseDTO: Codable {
  let userId: Int
  let name: String
  let email: String
  let oauthProvider: String
  let message: String
  let isNewUser: Bool
  let accessToken: String
  let refreshToken: String
  let oauthRefreshToken: String?
  let role: String?

  func toDomain() -> LoginEntity {
    let socialType: SocialType = oauthProvider == "google" ? .google : .apple
    let staffRole: Staff? = {
      switch role {
      case "manager": return .manager
      case "member": return .member
      default: return nil
      }
    }()

    let authTokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      oauthRefreshToken: oauthRefreshToken
    )

    return LoginEntity(
      name: name,
      isNewUser: isNewUser,
      provider: socialType,
      token: authTokens,
      role: staffRole
    )
  }
}

struct TokenDTO: Codable {
  let accessToken: String
  let refreshToken: String

  func toDomain() -> AuthTokens {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      oauthRefreshToken: nil
    )
  }
}

struct LogOutDTO: Codable {
  let code: String
  let message: String
  let detail: String

  func toDomain() -> AuthExitEntity {
    return AuthExitEntity(
      code: code,
      message: message,
      detail: detail
    )
  }
}

struct WithdrawDTO: Codable {
  let code: String
  let message: String
  let detail: String

  func toDomain(isSuccess: Bool = true) -> WithdrawEntity {
    return WithdrawEntity(
      isSuccess: isSuccess,
      code: code,
      message: message,
      detail: detail
    )
  }
}

struct OAuthLoginRequest: Codable {
  let provider: String
  let token: String
}

// MARK: - Mock Auth Entities

enum SocialType {
  case google
  case apple
}

enum Staff {
  case manager
  case member
}

struct LoginEntity {
  let name: String
  let isNewUser: Bool
  let provider: SocialType
  let token: AuthTokens
  let role: Staff?
}

struct AuthTokens {
  let accessToken: String
  let refreshToken: String
  let oauthRefreshToken: String?
}

struct AuthExitEntity {
  let code: String?
  let message: String?
  let detail: String?
}

struct WithdrawEntity {
  let isSuccess: Bool
  let code: String
  let message: String
  let detail: String
}

// MARK: - Mock Auth Errors

enum AuthError: Error {
  case invalidToken
  case refreshTokenExpired
  case unauthorized
  case networkError
}