//
//  BaseUserProfileDTO+Extensions.swift
//  Service
//
//  Created by Claude on 1/6/26.
//

//import Foundation
//import Entity
//
//// MARK: - UserSession에서 BaseUserProfileDTO 변환
//extension BaseUserProfileDTO {
//  /// UserSession에서 BaseUserProfileDTO를 생성
//  public static func from(userSession: UserSession) -> BaseUserProfileDTO {
//    return BaseUserProfileDTO(
//      name: userSession.name,
//      generationId: userSession.generationId,
//      jobRole: userSession.selectJob?.rawValue ?? "",
//      teamId: userSession.selectTeamId,
//      managerRoles: userSession.selectManging?.map { $0.rawValue }
//    )
//  }
//}
//
//// MARK: - ProfileEntity에서 BaseUserProfileDTO 변환 (추후 ProfileEntity가 있다면)
//extension BaseUserProfileDTO {
//  /// 기존 프로필 엔티티에서 BaseUserProfileDTO 생성
//  public static func from(
//    name: String,
//    generation: String,
//    jobRole: String,
//    teamId: Int?,
//    managerRoles: [String]?
//  ) -> BaseUserProfileDTO {
//    return BaseUserProfileDTO(
//      name: name,
//      generationId: Int(generation) ?? 0,
//      jobRole: jobRole,
//      teamId: teamId,
//      managerRoles: managerRoles
//    )
//  }
//}
//
//// MARK: - 편의 메서드들
//extension BaseUserProfileDTO {
//  /// 매니저 역할이 있는지 확인
//  public var isManager: Bool {
//    return !(managerRoles?.isEmpty ?? true)
//  }
//
//  /// 팀 관리 역할이 있는지 확인
//  public var isTeamManager: Bool {
//    return managerRoles?.contains("TEAM_MANAGING") ?? false
//  }
//
//  /// 출석 확인 역할이 있는지 확인
//  public var hasAttendanceCheckRole: Bool {
//    return managerRoles?.contains("ATTENDANCE_CHECK") ?? false
//  }
//}
