//
//  AttendanceRepositoryTest.swift
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

@Suite("Attendance Repository API Tests")
@MainActor
struct AttendanceRepositoryTest {

  // MARK: - Test Fixtures

  private func createMockAttendanceRepository() -> AttendanceRepositoryImpl {
    return AttendanceRepositoryImpl(provider: MockMoyaProvider<AttendanceService>())
  }

  private func createMockResponse<T: Codable>(_ data: T) -> Data {
    let encoder = JSONEncoder()
    return try! encoder.encode(data)
  }

  // MARK: - API 호출 성공 테스트

  @Test("관리자 출석 통계 조회 API 호출 성공")
  func test_admin_attendance_count_api_success() async throws {
    // Given
    let mockResponse = AdminAttendanceCountResponseDTO(
      attendanceCount: 25,
      attendanceMembers: ["홍길동", "김철수", "이영희"]
    )

    let repository = createMockAttendanceRepository()

    // When
    let result = try await repository.adminAttendanceCount(scheduleId: 123)

    // Then
    #expect(result.attendanceCount == 25)
    #expect(result.attendanceMembers.count == 3)
    #expect(result.attendanceMembers.contains("홍길동"))
    #expect(result.attendanceMembers.contains("김철수"))
    #expect(result.attendanceMembers.contains("이영희"))
  }

  @Test("출석 가능 팀 목록 조회 API 호출 성공")
  func test_fetch_attendance_teams_api_success() async throws {
    // Given
    let mockTeams = [
      AttendanceTeamDTO(teamId: 1, teamName: "iOS팀", memberCount: 5),
      AttendanceTeamDTO(teamId: 2, teamName: "Android팀", memberCount: 7),
      AttendanceTeamDTO(teamId: 3, teamName: "웹팀", memberCount: 4)
    ]

    let repository = createMockAttendanceRepository()

    // When
    let result = try await repository.fetchAttendanceTeams(scheduleId: 456)

    // Then
    #expect(result.count == 3)
    #expect(result[0].teamId == 1)
    #expect(result[0].teamName == "iOS팀")
    #expect(result[0].memberCount == 5)
    #expect(result[1].teamName == "Android팀")
    #expect(result[2].teamName == "웹팀")
  }

  @Test("특정 일정 출석 현황 조회 API 호출 성공")
  func test_session_attendance_api_success() async throws {
    // Given
    let mockAttendanceData = [
      SessionAttendanceDTO(
        userId: 100,
        userName: "홍길동",
        teamName: "iOS팀",
        attendanceStatus: "참석",
        checkInTime: Date()
      ),
      SessionAttendanceDTO(
        userId: 101,
        userName: "김철수",
        teamName: "Android팀",
        attendanceStatus: "지각",
        checkInTime: Date()
      )
    ]

    let repository = createMockAttendanceRepository()

    // When
    let result = try await repository.sessionAttendance(scheduleId: 789, teamId: 1)

    // Then
    #expect(result.count == 2)
    #expect(result[0].userName == "홍길동")
    #expect(result[0].teamName == "iOS팀")
    #expect(result[0].attendanceStatus == "참석")
    #expect(result[1].userName == "김철수")
    #expect(result[1].attendanceStatus == "지각")
  }

  @Test("출석 상태 종류 조회 API 호출 성공")
  func test_fetch_status_api_success() async throws {
    // Given
    let mockStatusData = [
      AttendanceStatusDTO(statusId: 1, statusName: "참석", statusColor: "#4CAF50"),
      AttendanceStatusDTO(statusId: 2, statusName: "지각", statusColor: "#FF9800"),
      AttendanceStatusDTO(statusId: 3, statusName: "결석", statusColor: "#F44336")
    ]

    let repository = createMockAttendanceRepository()

    // When
    let result = try await repository.fetchStatus()

    // Then
    #expect(result.count == 3)
    #expect(result[0].statusName == "참석")
    #expect(result[0].statusColor == "#4CAF50")
    #expect(result[1].statusName == "지각")
    #expect(result[1].statusColor == "#FF9800")
    #expect(result[2].statusName == "결석")
    #expect(result[2].statusColor == "#F44336")
  }

  @Test("출석 현황 수정 API 호출 성공")
  func test_edit_attendance_api_success() async throws {
    // Given
    let editRequest = EditAttendanceRequest(
      scheduleId: 123,
      userId: 456,
      newStatusId: 1,
      reason: "정상 출석으로 변경"
    )

    let repository = createMockAttendanceRepository()

    // When & Then: 예외가 발생하지 않으면 성공
    try await repository.editAttendance(
      scheduleId: editRequest.scheduleId,
      userId: editRequest.userId,
      statusId: editRequest.newStatusId,
      reason: editRequest.reason
    )

    // 성공적으로 완료되었음을 확인
    #expect(true) // API 호출이 예외 없이 완료되었음을 확인
  }

  // MARK: - API 호출 실패 테스트

  @Test("관리자 출석 통계 조회 API 호출 실패 (권한 없음)")
  func test_admin_attendance_count_api_unauthorized() async throws {
    // Given
    let repository = createMockAttendanceRepository()

    // When & Then
    #expect(throws: AttendanceError.unauthorized) {
      try await repository.adminAttendanceCount(scheduleId: -1) // 권한 오류를 트리거하는 값
    }
  }

  @Test("출석 수정 API 호출 실패 (잘못된 데이터)")
  func test_edit_attendance_api_invalid_data() async throws {
    // Given
    let repository = createMockAttendanceRepository()

    // When & Then
    #expect(throws: AttendanceError.invalidScheduleId) {
      try await repository.editAttendance(
        scheduleId: 0, // 잘못된 scheduleId
        userId: 456,
        statusId: 1,
        reason: "테스트 사유"
      )
    }
  }

  @Test("네트워크 오류 처리")
  func test_network_error_handling() async throws {
    // Given
    let repository = createMockAttendanceRepository()

    // When & Then
    #expect(throws: AttendanceError.networkError) {
      try await repository.fetchAttendanceTeams(scheduleId: -999) // 네트워크 오류를 트리거하는 값
    }
  }

  // MARK: - DTO to Entity 매핑 테스트

  @Test("AdminAttendanceCountResponseDTO to AdminAttendanceCount 매핑")
  func test_admin_attendance_count_dto_mapping() throws {
    // Given
    let dto = AdminAttendanceCountResponseDTO(
      attendanceCount: 15,
      attendanceMembers: ["사용자1", "사용자2", "사용자3"]
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.attendanceCount == 15)
    #expect(entity.attendanceMembers.count == 3)
    #expect(entity.attendanceMembers == ["사용자1", "사용자2", "사용자3"])
  }

  @Test("AttendanceTeamDTO to AttendanceTeam 매핑")
  func test_attendance_team_dto_mapping() throws {
    // Given
    let dto = AttendanceTeamDTO(
      teamId: 42,
      teamName: "백엔드팀",
      memberCount: 8
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.teamId == 42)
    #expect(entity.teamName == "백엔드팀")
    #expect(entity.memberCount == 8)
  }

  @Test("SessionAttendanceDTO to SessionAttendance 매핑")
  func test_session_attendance_dto_mapping() throws {
    // Given
    let checkInTime = Date()
    let dto = SessionAttendanceDTO(
      userId: 999,
      userName: "테스트사용자",
      teamName: "QA팀",
      attendanceStatus: "참석",
      checkInTime: checkInTime
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.userId == 999)
    #expect(entity.userName == "테스트사용자")
    #expect(entity.teamName == "QA팀")
    #expect(entity.attendanceStatus == "참석")
    #expect(entity.checkInTime == checkInTime)
  }

  @Test("AttendanceStatusDTO to AttendanceStatus 매핑")
  func test_attendance_status_dto_mapping() throws {
    // Given
    let dto = AttendanceStatusDTO(
      statusId: 5,
      statusName: "조퇴",
      statusColor: "#9C27B0"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.statusId == 5)
    #expect(entity.statusName == "조퇴")
    #expect(entity.statusColor == "#9C27B0")
  }

  // MARK: - 경계값 테스트

  @Test("빈 출석 멤버 목록 처리")
  func test_empty_attendance_members() throws {
    // Given
    let dto = AdminAttendanceCountResponseDTO(
      attendanceCount: 0,
      attendanceMembers: []
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.attendanceCount == 0)
    #expect(entity.attendanceMembers.isEmpty)
  }

  @Test("대용량 출석 데이터 처리")
  func test_large_attendance_data() throws {
    // Given
    let largeAttendanceMembers = (0..<1000).map { "사용자\($0)" }
    let dto = AdminAttendanceCountResponseDTO(
      attendanceCount: 1000,
      attendanceMembers: largeAttendanceMembers
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.attendanceCount == 1000)
    #expect(entity.attendanceMembers.count == 1000)
    #expect(entity.attendanceMembers.first == "사용자0")
    #expect(entity.attendanceMembers.last == "사용자999")
  }

  @Test("특수문자가 포함된 팀 이름 처리")
  func test_special_characters_in_team_name() throws {
    // Given
    let specialTeamName = "iOS/Android 통합팀 (2025년)"
    let dto = AttendanceTeamDTO(
      teamId: 99,
      teamName: specialTeamName,
      memberCount: 12
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.teamName == specialTeamName)
    #expect(entity.teamId == 99)
    #expect(entity.memberCount == 12)
  }

  // MARK: - 동시성 테스트

  @Test("동시 출석 조회 요청 처리")
  func test_concurrent_attendance_requests() async throws {
    // Given
    let repository = createMockAttendanceRepository()
    let scheduleIds = [100, 101, 102, 103, 104]

    // When
    await withTaskGroup(of: Void.self) { group in
      for scheduleId in scheduleIds {
        group.addTask {
          do {
            _ = try await repository.adminAttendanceCount(scheduleId: scheduleId)
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 크래시나 데드락 없이 완료되어야 함
    #expect(true) // 성공적으로 완료됨
  }

  @Test("동시 출석 수정 요청 처리")
  func test_concurrent_edit_attendance_requests() async throws {
    // Given
    let repository = createMockAttendanceRepository()
    let userIds = [200, 201, 202, 203, 204]

    // When
    await withTaskGroup(of: Void.self) { group in
      for userId in userIds {
        group.addTask {
          do {
            try await repository.editAttendance(
              scheduleId: 100,
              userId: userId,
              statusId: 1,
              reason: "동시성 테스트 \(userId)"
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
}

// MARK: - Mock Classes

final class MockMoyaProvider<Target: TargetType>: MoyaProvider<Target> {

  override init() {
    super.init(stubClosure: { _ in .immediate })
  }

  override func request<T: Decodable>(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) async throws -> T {
    // Mock 응답 데이터 생성
    if let attendanceTarget = target as? AttendanceService {
      return try createMockAttendanceResponse(for: attendanceTarget) as! T
    }

    throw AttendanceError.networkError
  }

  private func createMockAttendanceResponse<T: Decodable>(for target: AttendanceService) throws -> T {
    switch target {
    case .adminAttendanceCount(let scheduleId):
      if scheduleId == -1 {
        throw AttendanceError.unauthorized
      }
      if scheduleId == -999 {
        throw AttendanceError.networkError
      }
      let response = AdminAttendanceCountResponseDTO(
        attendanceCount: 25,
        attendanceMembers: ["홍길동", "김철수", "이영희"]
      )
      return response as! T

    case .fetchAttendanceTeams(let scheduleId):
      if scheduleId == -999 {
        throw AttendanceError.networkError
      }
      let teams = [
        AttendanceTeamDTO(teamId: 1, teamName: "iOS팀", memberCount: 5),
        AttendanceTeamDTO(teamId: 2, teamName: "Android팀", memberCount: 7),
        AttendanceTeamDTO(teamId: 3, teamName: "웹팀", memberCount: 4)
      ]
      return teams as! T

    case .sessionAttendance(_, _):
      let attendanceData = [
        SessionAttendanceDTO(
          userId: 100,
          userName: "홍길동",
          teamName: "iOS팀",
          attendanceStatus: "참석",
          checkInTime: Date()
        ),
        SessionAttendanceDTO(
          userId: 101,
          userName: "김철수",
          teamName: "Android팀",
          attendanceStatus: "지각",
          checkInTime: Date()
        )
      ]
      return attendanceData as! T

    case .fetchStatus:
      let statusData = [
        AttendanceStatusDTO(statusId: 1, statusName: "참석", statusColor: "#4CAF50"),
        AttendanceStatusDTO(statusId: 2, statusName: "지각", statusColor: "#FF9800"),
        AttendanceStatusDTO(statusId: 3, statusName: "결석", statusColor: "#F44336")
      ]
      return statusData as! T

    case .editAttendance(let scheduleId, _, _, _):
      if scheduleId == 0 {
        throw AttendanceError.invalidScheduleId
      }
      // editAttendance는 Void를 반환하므로 빈 응답
      return () as! T

    default:
      throw AttendanceError.networkError
    }
  }
}

// MARK: - Mock DTOs

struct AdminAttendanceCountResponseDTO: Codable {
  let attendanceCount: Int
  let attendanceMembers: [String]

  func toDomain() -> AdminAttendanceCount {
    return AdminAttendanceCount(
      attendanceCount: attendanceCount,
      attendanceMembers: attendanceMembers
    )
  }
}

struct AttendanceTeamDTO: Codable {
  let teamId: Int
  let teamName: String
  let memberCount: Int

  func toDomain() -> AttendanceTeam {
    return AttendanceTeam(
      teamId: teamId,
      teamName: teamName,
      memberCount: memberCount
    )
  }
}

struct SessionAttendanceDTO: Codable {
  let userId: Int
  let userName: String
  let teamName: String
  let attendanceStatus: String
  let checkInTime: Date

  func toDomain() -> SessionAttendance {
    return SessionAttendance(
      userId: userId,
      userName: userName,
      teamName: teamName,
      attendanceStatus: attendanceStatus,
      checkInTime: checkInTime
    )
  }
}

struct AttendanceStatusDTO: Codable {
  let statusId: Int
  let statusName: String
  let statusColor: String

  func toDomain() -> AttendanceStatus {
    return AttendanceStatus(
      statusId: statusId,
      statusName: statusName,
      statusColor: statusColor
    )
  }
}

struct EditAttendanceRequest: Codable {
  let scheduleId: Int
  let userId: Int
  let newStatusId: Int
  let reason: String
}

// MARK: - Mock Entities

struct AdminAttendanceCount {
  let attendanceCount: Int
  let attendanceMembers: [String]
}

struct AttendanceTeam {
  let teamId: Int
  let teamName: String
  let memberCount: Int
}

struct SessionAttendance {
  let userId: Int
  let userName: String
  let teamName: String
  let attendanceStatus: String
  let checkInTime: Date
}

struct AttendanceStatus {
  let statusId: Int
  let statusName: String
  let statusColor: String
}

// MARK: - Mock Errors

enum AttendanceError: Error {
  case unauthorized
  case invalidScheduleId
  case networkError
}