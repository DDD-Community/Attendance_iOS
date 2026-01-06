//
//  DefaultProfileRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import Entity

/// Mock 구현체 - 테스트/프리뷰용 ProfileRepository
final public class DefaultProfileRepositoryImpl: ProfileInterface {

  private var mockUserType: MockUserType

  public init(mockUserType: MockUserType = .member) {
    self.mockUserType = mockUserType
  }

  public func getProfile() async throws -> ProfileEntity {
    // 네트워크 호출 시뮬레이션
    try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기

    switch mockUserType {
    case .member:
      return createMemberProfile()
    case .teamManager:
      return createTeamManagerProfile()
    case .staff:
      return createStaffProfile()
    }
  }

  public func editProfile(input: Entity.EditProfileInput) async throws -> Entity.ProfileEntity {
    // 네트워크 호출 시뮬레이션
    try await Task.sleep(nanoseconds: 800_000_000) // 0.8초 대기

    // generationId를 문자열로 변환
    let generation = "\(input.generationId)기"

    // teamId를 SelectTeams enum으로 변환 (Mock용 간단 매핑)
    let team: SelectTeams? = {
      guard let teamId = input.teamId else { return nil }
      switch teamId {
      case 1: return .ios1
      case 2: return .ios2
      case 3: return .and1
      case 4: return .and2
      default: return .ios1 // 기본값
      }
    }()

    // 매니저 역할이 있으면 manager, 없으면 member로 설정
    let role: Staff = (input.managerRoles?.isEmpty == false) ? .manager : .member

    // 수정된 프로필 반환
    let updatedProfile = ProfileEntity(
      name: input.name,
      generation: generation,
      team: team,
      jobRole: input.jobRole,
      role: role,
      manger: input.managerRoles
    )

    // Mock이므로 업데이트된 값 그대로 반환
    return updatedProfile
  }

  /// Mock 사용자 타입 변경
  public func setMockUserType(_ type: MockUserType) {
    self.mockUserType = type
  }
}

// MARK: - Mock Data Factory

public enum MockUserType {
  case member
  case teamManager
  case staff
}

private extension DefaultProfileRepositoryImpl {

  func createMemberProfile() -> ProfileEntity {
    return ProfileEntity(
      name: "김철수",
      generation: "2기",
      team: .ios1,
      jobRole: .ios,
      role: .member,
      manger: nil
    )
  }

  func createTeamManagerProfile() -> ProfileEntity {
    return ProfileEntity(
      name: "이영희",
      generation: "1기",
      team: .and1,
      jobRole: .android,
      role: .manager,
      manger: [.teamManaging]
    )
  }

  func createStaffProfile() -> ProfileEntity {
    return ProfileEntity(
      name: "박관리",
      generation: "0기",
      team: nil,
      jobRole: .pm,
      role: .manager,
      manger: [.teamManaging, .scheduleReminder, .attendanceCheck]
    )
  }
}

