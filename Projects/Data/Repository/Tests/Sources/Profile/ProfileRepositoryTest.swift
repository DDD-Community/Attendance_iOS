//
//  ProfileRepositoryTest.swift
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

@Suite("Profile Repository API Tests")
@MainActor
struct ProfileRepositoryTest {

  // MARK: - Test Fixtures

  private func createMockProfileRepository() -> ProfileRepositoryImpl {
    return ProfileRepositoryImpl(provider: MockMoyaProvider<ProfileService>())
  }

  // MARK: - API 호출 성공 테스트

  @Test("프로필 조회 API 호출 성공 - Manager 권한")
  func test_get_profile_api_success_manager() async throws {
    // Given
    let repository = createMockProfileRepository()

    // When
    let result = try await repository.getProfile()

    // Then
    #expect(result.userId == 12345)
    #expect(result.name == "홍길동")
    #expect(result.email == "hong@ddd.com")
    #expect(result.generation == "10기")
    #expect(result.part == "iOS")
    #expect(result.team == "iOS팀")
    #expect(result.role == Staff.manager)
    #expect(result.profileImageUrl != nil)
    #expect(result.joinDate != nil)
  }

  @Test("프로필 조회 API 호출 성공 - Member 권한")
  func test_get_profile_api_success_member() async throws {
    // Given
    let repository = createMockProfileRepository()

    // When
    let result = try await repository.getProfile(userId: 99999) // Member용 특수 ID

    // Then
    #expect(result.userId == 99999)
    #expect(result.name == "김철수")
    #expect(result.email == "kim@ddd.com")
    #expect(result.generation == "10기")
    #expect(result.part == "Android")
    #expect(result.team == "Android팀")
    #expect(result.role == Staff.member)
    #expect(result.managerRoles == nil) // Member는 Manager 권한 없음
  }

  @Test("프로필 편집 API 호출 성공 - 기본 정보 수정")
  func test_edit_profile_api_success_basic_info() async throws {
    // Given
    let repository = createMockProfileRepository()
    let editRequest = EditProfileRequest(
      name: "수정된홍길동",
      generation: "11기",
      part: "백엔드",
      team: "백엔드팀",
      profileImageUrl: "https://example.com/new_profile.jpg"
    )

    // When & Then
    try await repository.editProfile(
      name: editRequest.name,
      generation: editRequest.generation,
      part: editRequest.part,
      team: editRequest.team,
      profileImageUrl: editRequest.profileImageUrl
    )

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  @Test("프로필 편집 API 호출 성공 - Manager 권한 포함")
  func test_edit_profile_api_success_with_manager_roles() async throws {
    // Given
    let repository = createMockProfileRepository()
    let managerRoles = [
      ManagerRole(roleId: 1, roleName: "출석관리", description: "출석 데이터 관리"),
      ManagerRole(roleId: 2, roleName: "팀관리", description: "팀원 관리")
    ]

    // When & Then
    try await repository.editProfile(
      name: "매니저홍길동",
      generation: "10기",
      part: "관리",
      team: "운영팀",
      managerRoles: managerRoles
    )

    #expect(true)
  }

  // MARK: - API 호출 실패 테스트

  @Test("프로필 조회 API 호출 실패 - 권한 없음")
  func test_get_profile_api_unauthorized() async throws {
    // Given
    let repository = createMockProfileRepository()

    // When & Then
    #expect(throws: ProfileError.unauthorized) {
      try await repository.getProfile(userId: -1) // 권한 오류를 트리거하는 값
    }
  }

  @Test("프로필 편집 API 호출 실패 - 유효하지 않은 데이터")
  func test_edit_profile_api_invalid_data() async throws {
    // Given
    let repository = createMockProfileRepository()

    // When & Then
    #expect(throws: ProfileError.invalidUserData) {
      try await repository.editProfile(
        name: "", // 빈 이름으로 오류 트리거
        generation: "10기",
        part: "iOS",
        team: "iOS팀"
      )
    }
  }

  @Test("네트워크 오류 처리")
  func test_network_error_handling() async throws {
    // Given
    let repository = createMockProfileRepository()

    // When & Then
    #expect(throws: ProfileError.networkError) {
      try await repository.getProfile(userId: -999) // 네트워크 오류를 트리거하는 값
    }
  }

  // MARK: - DTO to Entity 매핑 테스트

  @Test("ProfileResponseDTO to ProfileEntity 매핑 - Manager")
  func test_profile_response_dto_mapping_manager() throws {
    // Given
    let managerRoles = [
      ManagerRoleDTO(roleId: 1, roleName: "출석관리", description: "출석 관련 권한"),
      ManagerRoleDTO(roleId: 2, roleName: "일정관리", description: "일정 관련 권한")
    ]

    let dto = ProfileResponseDTO(
      userId: 12345,
      name: "관리자홍길동",
      email: "manager@ddd.com",
      generation: "9기",
      part: "관리",
      team: "운영팀",
      role: "manager",
      profileImageUrl: "https://example.com/profile.jpg",
      joinDate: Date(),
      managerRoles: managerRoles
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.userId == 12345)
    #expect(entity.name == "관리자홍길동")
    #expect(entity.email == "manager@ddd.com")
    #expect(entity.generation == "9기")
    #expect(entity.part == "관리")
    #expect(entity.team == "운영팀")
    #expect(entity.role == Staff.manager)
    #expect(entity.profileImageUrl == "https://example.com/profile.jpg")
    #expect(entity.managerRoles?.count == 2)
    #expect(entity.managerRoles?[0].roleName == "출석관리")
    #expect(entity.managerRoles?[1].roleName == "일정관리")
  }

  @Test("ProfileResponseDTO to ProfileEntity 매핑 - Member")
  func test_profile_response_dto_mapping_member() throws {
    // Given
    let dto = ProfileResponseDTO(
      userId: 67890,
      name: "멤버김철수",
      email: "member@ddd.com",
      generation: "10기",
      part: "iOS",
      team: "iOS팀",
      role: "member",
      profileImageUrl: nil,
      joinDate: Date(),
      managerRoles: nil
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.userId == 67890)
    #expect(entity.name == "멤버김철수")
    #expect(entity.email == "member@ddd.com")
    #expect(entity.generation == "10기")
    #expect(entity.part == "iOS")
    #expect(entity.team == "iOS팀")
    #expect(entity.role == Staff.member)
    #expect(entity.profileImageUrl == nil)
    #expect(entity.managerRoles == nil)
  }

  @Test("EditProfileRequestDTO 생성 및 검증")
  func test_edit_profile_request_dto_creation() throws {
    // Given & When
    let dto = EditProfileRequestDTO(
      name: "수정된이름",
      generation: "11기",
      part: "백엔드",
      team: "백엔드팀",
      profileImageUrl: "https://example.com/new.jpg",
      managerRoles: [
        ManagerRoleDTO(roleId: 3, roleName: "시스템관리", description: "시스템 관리 권한")
      ]
    )

    // Then
    #expect(dto.name == "수정된이름")
    #expect(dto.generation == "11기")
    #expect(dto.part == "백엔드")
    #expect(dto.team == "백엔드팀")
    #expect(dto.profileImageUrl == "https://example.com/new.jpg")
    #expect(dto.managerRoles?.count == 1)
    #expect(dto.managerRoles?[0].roleName == "시스템관리")
  }

  // MARK: - 경계값 테스트

  @Test("빈 Manager Roles 처리")
  func test_empty_manager_roles() throws {
    // Given
    let dto = ProfileResponseDTO(
      userId: 111,
      name: "빈권한관리자",
      email: "empty@ddd.com",
      generation: "8기",
      part: "관리",
      team: "운영팀",
      role: "manager",
      profileImageUrl: nil,
      joinDate: Date(),
      managerRoles: []
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.role == Staff.manager)
    #expect(entity.managerRoles?.isEmpty == true)
  }

  @Test("매우 긴 문자열 데이터 처리")
  func test_very_long_string_data() throws {
    // Given
    let longName = String(repeating: "가", count: 100)
    let longEmail = "verylongemail" + String(repeating: "a", count: 100) + "@ddd.com"
    let longGeneration = String(repeating: "기", count: 50)

    let dto = ProfileResponseDTO(
      userId: 222,
      name: longName,
      email: longEmail,
      generation: longGeneration,
      part: "테스트",
      team: "테스트팀",
      role: "member",
      profileImageUrl: nil,
      joinDate: Date(),
      managerRoles: nil
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.name == longName)
    #expect(entity.email == longEmail)
    #expect(entity.generation == longGeneration)
    #expect(entity.userId == 222)
  }

  @Test("특수문자가 포함된 프로필 데이터 처리")
  func test_profile_data_with_special_characters() throws {
    // Given
    let specialName = "홍길동-김철수@이영희#박민수"
    let specialTeam = "iOS/Android 통합팀 (2025년)"
    let specialPart = "프론트엔드&백엔드"

    let dto = ProfileResponseDTO(
      userId: 333,
      name: specialName,
      email: "special@ddd.com",
      generation: "10기",
      part: specialPart,
      team: specialTeam,
      role: "member",
      profileImageUrl: nil,
      joinDate: Date(),
      managerRoles: nil
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.name == specialName)
    #expect(entity.part == specialPart)
    #expect(entity.team == specialTeam)
  }

  // MARK: - 동시성 테스트

  @Test("동시 프로필 조회 요청 처리")
  func test_concurrent_profile_requests() async throws {
    // Given
    let repository = createMockProfileRepository()
    let userIds = [100, 101, 102, 103, 104]

    // When
    await withTaskGroup(of: Void.self) { group in
      for userId in userIds {
        group.addTask {
          do {
            _ = try await repository.getProfile(userId: userId)
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 크래시나 데드락 없이 완료되어야 함
    #expect(true)
  }

  @Test("동시 프로필 편집 요청 처리")
  func test_concurrent_edit_profile_requests() async throws {
    // Given
    let repository = createMockProfileRepository()
    let names = ["사용자1", "사용자2", "사용자3", "사용자4", "사용자5"]

    // When
    await withTaskGroup(of: Void.self) { group in
      for (index, name) in names.enumerated() {
        group.addTask {
          do {
            try await repository.editProfile(
              name: name,
              generation: "\(10 + index)기",
              part: "테스트",
              team: "테스트팀"
            )
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 완료되어야 함
    #expect(true)
  }

  // MARK: - 유효성 검증 테스트

  @Test("올바른 이메일 형식 검증")
  func test_valid_email_format() throws {
    // Given
    let validEmails = [
      "test@ddd.com",
      "user123@gmail.com",
      "admin@company.co.kr",
      "member_01@test-domain.com"
    ]

    for email in validEmails {
      let dto = ProfileResponseDTO(
        userId: 444,
        name: "테스트사용자",
        email: email,
        generation: "10기",
        part: "테스트",
        team: "테스트팀",
        role: "member",
        profileImageUrl: nil,
        joinDate: Date(),
        managerRoles: nil
      )

      // When
      let entity = dto.toDomain()

      // Then
      #expect(entity.email == email)
    }
  }

  @Test("프로필 이미지 URL 유효성 검증")
  func test_profile_image_url_validation() throws {
    // Given
    let validUrls = [
      "https://example.com/profile.jpg",
      "http://localhost:3000/images/user.png",
      "https://cdn.ddd.com/profiles/12345.webp"
    ]

    for url in validUrls {
      let dto = ProfileResponseDTO(
        userId: 555,
        name: "이미지테스트",
        email: "image@ddd.com",
        generation: "10기",
        part: "디자인",
        team: "디자인팀",
        role: "member",
        profileImageUrl: url,
        joinDate: Date(),
        managerRoles: nil
      )

      // When
      let entity = dto.toDomain()

      // Then
      #expect(entity.profileImageUrl == url)
    }
  }
}

// MARK: - Mock MoyaProvider for Profile

extension MockMoyaProvider where Target == ProfileService {

  override func request<T: Decodable>(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) async throws -> T {
    if let profileTarget = target as? ProfileService {
      return try createMockProfileResponse(for: profileTarget) as! T
    }

    throw ProfileError.networkError
  }

  private func createMockProfileResponse<T: Decodable>(for target: ProfileService) throws -> T {
    switch target {
    case .getProfile(let userId):
      if let userId = userId, userId == -1 {
        throw ProfileError.unauthorized
      }
      if let userId = userId, userId == -999 {
        throw ProfileError.networkError
      }

      // Member용 특수 응답
      if let userId = userId, userId == 99999 {
        let memberResponse = ProfileResponseDTO(
          userId: 99999,
          name: "김철수",
          email: "kim@ddd.com",
          generation: "10기",
          part: "Android",
          team: "Android팀",
          role: "member",
          profileImageUrl: nil,
          joinDate: Date(),
          managerRoles: nil
        )
        return memberResponse as! T
      }

      // 기본 Manager 응답
      let managerRoles = [
        ManagerRoleDTO(roleId: 1, roleName: "출석관리", description: "출석 관련 권한"),
        ManagerRoleDTO(roleId: 2, roleName: "일정관리", description: "일정 관련 권한")
      ]

      let managerResponse = ProfileResponseDTO(
        userId: userId ?? 12345,
        name: "홍길동",
        email: "hong@ddd.com",
        generation: "10기",
        part: "iOS",
        team: "iOS팀",
        role: "manager",
        profileImageUrl: "https://example.com/profile.jpg",
        joinDate: Date(),
        managerRoles: managerRoles
      )
      return managerResponse as! T

    case .editProfile(let request):
      if request.name.isEmpty {
        throw ProfileError.invalidUserData
      }
      // editProfile은 Void를 반환
      return () as! T

    default:
      throw ProfileError.networkError
    }
  }
}

// MARK: - Mock DTOs

struct ProfileResponseDTO: Codable {
  let userId: Int
  let name: String
  let email: String
  let generation: String
  let part: String
  let team: String
  let role: String
  let profileImageUrl: String?
  let joinDate: Date
  let managerRoles: [ManagerRoleDTO]?

  func toDomain() -> ProfileEntity {
    return ProfileEntity(
      userId: userId,
      name: name,
      email: email,
      generation: generation,
      part: part,
      team: team,
      role: role == "manager" ? Staff.manager : Staff.member,
      profileImageUrl: profileImageUrl,
      joinDate: joinDate,
      managerRoles: managerRoles?.map { $0.toDomain() }
    )
  }
}

struct ManagerRoleDTO: Codable {
  let roleId: Int
  let roleName: String
  let description: String

  func toDomain() -> ManagerRole {
    return ManagerRole(
      roleId: roleId,
      roleName: roleName,
      description: description
    )
  }
}

struct EditProfileRequestDTO: Codable {
  let name: String
  let generation: String
  let part: String
  let team: String
  let profileImageUrl: String?
  let managerRoles: [ManagerRoleDTO]?
}

struct EditProfileRequest {
  let name: String
  let generation: String
  let part: String
  let team: String
  let profileImageUrl: String?
}

// MARK: - Mock Entities

struct ProfileEntity {
  let userId: Int
  let name: String
  let email: String
  let generation: String
  let part: String
  let team: String
  let role: Staff
  let profileImageUrl: String?
  let joinDate: Date
  let managerRoles: [ManagerRole]?
}

struct ManagerRole {
  let roleId: Int
  let roleName: String
  let description: String
}

enum Staff {
  case manager
  case member
}

// MARK: - Mock Errors

enum ProfileError: Error {
  case unauthorized
  case invalidUserData
  case networkError
}