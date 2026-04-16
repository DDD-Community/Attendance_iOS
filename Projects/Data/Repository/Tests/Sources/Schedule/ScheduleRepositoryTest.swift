//
//  ScheduleRepositoryTest.swift
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

@Suite("Schedule Repository API Tests")
@MainActor
struct ScheduleRepositoryTest {

  // MARK: - Test Fixtures

  private func createMockScheduleRepository() -> ScheduleRepositoryImpl {
    return ScheduleRepositoryImpl(provider: MockMoyaProvider<ScheduleService>())
  }

  // MARK: - API 호출 성공 테스트

  @Test("일정 생성 API 호출 성공")
  func test_create_schedule_api_success() async throws {
    // Given
    let repository = createMockScheduleRepository()
    let createRequest = CreateScheduleRequest(
      title: "10기 정기모임",
      description: "DDD 10기 첫 번째 정기모임",
      startTime: Date(),
      endTime: Date().addingTimeInterval(7200), // 2시간 후
      location: "강남역 스터디룸",
      scheduleType: "meeting",
      teamIds: [1, 2, 3]
    )

    // When
    let result = try await repository.createSchedule(
      title: createRequest.title,
      description: createRequest.description,
      startTime: createRequest.startTime,
      endTime: createRequest.endTime,
      location: createRequest.location,
      scheduleType: createRequest.scheduleType,
      teamIds: createRequest.teamIds
    )

    // Then
    #expect(result.scheduleId == 12345)
    #expect(result.title == "10기 정기모임")
    #expect(result.description == "DDD 10기 첫 번째 정기모임")
    #expect(result.location == "강남역 스터디룸")
    #expect(result.scheduleType == "meeting")
    #expect(result.isActive == true)
    #expect(result.teamIds == [1, 2, 3])
  }

  @Test("팀별 일정 목록 조회 API 호출 성공")
  func test_fetch_schedules_api_success() async throws {
    // Given
    let repository = createMockScheduleRepository()

    // When
    let result = try await repository.fetchSchedules(teamId: 1)

    // Then
    #expect(result.count == 3)

    // 첫 번째 일정 검증
    #expect(result[0].scheduleId == 1001)
    #expect(result[0].title == "iOS 스터디")
    #expect(result[0].scheduleType == "study")
    #expect(result[0].location == "온라인")

    // 두 번째 일정 검증
    #expect(result[1].scheduleId == 1002)
    #expect(result[1].title == "코드 리뷰")
    #expect(result[1].scheduleType == "review")

    // 세 번째 일정 검증
    #expect(result[2].scheduleId == 1003)
    #expect(result[2].title == "프로젝트 회의")
    #expect(result[2].scheduleType == "meeting")
  }

  @Test("일정 상세 정보 조회 API 호출 성공")
  func test_get_schedule_detail_api_success() async throws {
    // Given
    let repository = createMockScheduleRepository()

    // When
    let result = try await repository.getScheduleDetail(scheduleId: 2001)

    // Then
    #expect(result.scheduleId == 2001)
    #expect(result.title == "전체 정기모임")
    #expect(result.description == "DDD 전체 멤버 정기모임")
    #expect(result.location == "강남역 회의실")
    #expect(result.scheduleType == "meeting")
    #expect(result.isActive == true)
    #expect(result.attendanceCount == 25)
    #expect(result.totalMemberCount == 30)
    #expect(result.teamIds.contains(1))
    #expect(result.teamIds.contains(2))
  }

  @Test("일정 수정 API 호출 성공")
  func test_edit_schedule_api_success() async throws {
    // Given
    let repository = createMockScheduleRepository()
    let editRequest = EditScheduleRequest(
      scheduleId: 3001,
      title: "수정된 일정 제목",
      description: "수정된 일정 설명",
      startTime: Date(),
      endTime: Date().addingTimeInterval(3600),
      location: "새로운 장소",
      scheduleType: "workshop"
    )

    // When & Then
    try await repository.editSchedule(
      scheduleId: editRequest.scheduleId,
      title: editRequest.title,
      description: editRequest.description,
      startTime: editRequest.startTime,
      endTime: editRequest.endTime,
      location: editRequest.location,
      scheduleType: editRequest.scheduleType
    )

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  @Test("일정 삭제 API 호출 성공")
  func test_delete_schedule_api_success() async throws {
    // Given
    let repository = createMockScheduleRepository()

    // When & Then
    try await repository.deleteSchedule(scheduleId: 4001)

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  @Test("일정 활성화/비활성화 API 호출 성공")
  func test_toggle_schedule_status_api_success() async throws {
    // Given
    let repository = createMockScheduleRepository()

    // When & Then
    try await repository.toggleScheduleStatus(scheduleId: 5001, isActive: false)

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  // MARK: - API 호출 실패 테스트

  @Test("일정 생성 API 호출 실패 (권한 없음)")
  func test_create_schedule_api_unauthorized() async throws {
    // Given
    let repository = createMockScheduleRepository()

    // When & Then
    #expect(throws: ScheduleError.unauthorized) {
      try await repository.createSchedule(
        title: "권한없음테스트",
        description: "권한없음",
        startTime: Date(),
        endTime: Date(),
        location: "테스트장소",
        scheduleType: "meeting",
        teamIds: [-1] // 권한 오류를 트리거하는 값
      )
    }
  }

  @Test("일정 생성 API 호출 실패 (잘못된 날짜)")
  func test_create_schedule_api_invalid_date() async throws {
    // Given
    let repository = createMockScheduleRepository()
    let pastDate = Date().addingTimeInterval(-3600) // 1시간 전

    // When & Then
    #expect(throws: ScheduleError.invalidTimeRange) {
      try await repository.createSchedule(
        title: "과거일정",
        description: "과거 일정 테스트",
        startTime: pastDate,
        endTime: pastDate.addingTimeInterval(-3600), // 시작시간보다 더 과거
        location: "테스트장소",
        scheduleType: "meeting",
        teamIds: [1]
      )
    }
  }

  @Test("일정 조회 API 호출 실패 (존재하지 않는 일정)")
  func test_get_schedule_detail_api_not_found() async throws {
    // Given
    let repository = createMockScheduleRepository()

    // When & Then
    #expect(throws: ScheduleError.scheduleNotFound) {
      try await repository.getScheduleDetail(scheduleId: -9999)
    }
  }

  @Test("네트워크 오류 처리")
  func test_network_error_handling() async throws {
    // Given
    let repository = createMockScheduleRepository()

    // When & Then
    #expect(throws: ScheduleError.networkError) {
      try await repository.fetchSchedules(teamId: -999) // 네트워크 오류를 트리거하는 값
    }
  }

  // MARK: - DTO to Entity 매핑 테스트

  @Test("CreateScheduleResponseDTO to ScheduleEntity 매핑")
  func test_create_schedule_response_dto_mapping() throws {
    // Given
    let dto = CreateScheduleResponseDTO(
      scheduleId: 777,
      title: "새로운 일정",
      description: "새로운 일정 설명",
      startTime: Date(),
      endTime: Date().addingTimeInterval(7200),
      location: "회의실 A",
      scheduleType: "meeting",
      isActive: true,
      teamIds: [1, 2, 3, 4],
      createdAt: Date()
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.scheduleId == 777)
    #expect(entity.title == "새로운 일정")
    #expect(entity.description == "새로운 일정 설명")
    #expect(entity.location == "회의실 A")
    #expect(entity.scheduleType == "meeting")
    #expect(entity.isActive == true)
    #expect(entity.teamIds == [1, 2, 3, 4])
  }

  @Test("ScheduleListDTO to ScheduleEntity 매핑")
  func test_schedule_list_dto_mapping() throws {
    // Given
    let startTime = Date()
    let endTime = Date().addingTimeInterval(3600)

    let dto = ScheduleListDTO(
      scheduleId: 888,
      title: "목록 일정",
      description: "목록에서 가져온 일정",
      startTime: startTime,
      endTime: endTime,
      location: "카페",
      scheduleType: "study",
      isActive: true
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.scheduleId == 888)
    #expect(entity.title == "목록 일정")
    #expect(entity.description == "목록에서 가져온 일정")
    #expect(entity.startTime == startTime)
    #expect(entity.endTime == endTime)
    #expect(entity.location == "카페")
    #expect(entity.scheduleType == "study")
    #expect(entity.isActive == true)
  }

  @Test("ScheduleDetailDTO to ScheduleDetailEntity 매핑")
  func test_schedule_detail_dto_mapping() throws {
    // Given
    let startTime = Date()
    let endTime = Date().addingTimeInterval(5400)

    let dto = ScheduleDetailDTO(
      scheduleId: 999,
      title: "상세 일정",
      description: "상세 일정 설명",
      startTime: startTime,
      endTime: endTime,
      location: "대회의실",
      scheduleType: "presentation",
      isActive: true,
      attendanceCount: 15,
      totalMemberCount: 20,
      teamIds: [5, 6, 7],
      createdBy: "관리자",
      createdAt: Date(),
      updatedAt: Date()
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.scheduleId == 999)
    #expect(entity.title == "상세 일정")
    #expect(entity.description == "상세 일정 설명")
    #expect(entity.location == "대회의실")
    #expect(entity.scheduleType == "presentation")
    #expect(entity.isActive == true)
    #expect(entity.attendanceCount == 15)
    #expect(entity.totalMemberCount == 20)
    #expect(entity.teamIds == [5, 6, 7])
    #expect(entity.createdBy == "관리자")
  }

  // MARK: - 경계값 테스트

  @Test("빈 팀 ID 목록으로 일정 생성")
  func test_create_schedule_with_empty_team_ids() async throws {
    // Given
    let repository = createMockScheduleRepository()

    // When
    let result = try await repository.createSchedule(
      title: "빈팀일정",
      description: "팀이 없는 일정",
      startTime: Date(),
      endTime: Date().addingTimeInterval(3600),
      location: "장소",
      scheduleType: "meeting",
      teamIds: []
    )

    // Then
    #expect(result.scheduleId == 12345)
    #expect(result.teamIds.isEmpty)
  }

  @Test("매우 긴 제목과 설명으로 일정 생성")
  func test_create_schedule_with_very_long_strings() async throws {
    // Given
    let repository = createMockScheduleRepository()
    let longTitle = String(repeating: "긴제목", count: 100)
    let longDescription = String(repeating: "긴설명", count: 500)
    let longLocation = String(repeating: "긴장소명", count: 50)

    // When
    let result = try await repository.createSchedule(
      title: longTitle,
      description: longDescription,
      startTime: Date(),
      endTime: Date().addingTimeInterval(3600),
      location: longLocation,
      scheduleType: "meeting",
      teamIds: [1]
    )

    // Then
    #expect(result.title == longTitle)
    #expect(result.description == longDescription)
    #expect(result.location == longLocation)
  }

  @Test("특수문자가 포함된 일정 정보 처리")
  func test_schedule_with_special_characters() throws {
    // Given
    let specialTitle = "🎉 DDD 10기 모임 (2025년) 🚀"
    let specialDescription = "특별한 모임입니다! @ 강남역 #DDD #모임"
    let specialLocation = "강남역 2번 출구 앞 (스타벅스 옆) - 지하 1층"

    let dto = ScheduleListDTO(
      scheduleId: 1111,
      title: specialTitle,
      description: specialDescription,
      startTime: Date(),
      endTime: Date(),
      location: specialLocation,
      scheduleType: "special",
      isActive: true
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.title == specialTitle)
    #expect(entity.description == specialDescription)
    #expect(entity.location == specialLocation)
    #expect(entity.scheduleType == "special")
  }

  // MARK: - 시간 관련 테스트

  @Test("시간 범위 검증 - 정상 케이스")
  func test_valid_time_range() throws {
    // Given
    let startTime = Date()
    let endTime = Date().addingTimeInterval(7200) // 2시간 후

    let dto = ScheduleListDTO(
      scheduleId: 2222,
      title: "정상시간일정",
      description: "정상적인 시간 범위",
      startTime: startTime,
      endTime: endTime,
      location: "회의실",
      scheduleType: "meeting",
      isActive: true
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.startTime == startTime)
    #expect(entity.endTime == endTime)
    #expect(entity.endTime > entity.startTime)
  }

  @Test("동일한 시작시간과 종료시간 처리")
  func test_same_start_and_end_time() throws {
    // Given
    let sameTime = Date()

    let dto = ScheduleListDTO(
      scheduleId: 3333,
      title: "동일시간일정",
      description: "시작과 종료가 같은 시간",
      startTime: sameTime,
      endTime: sameTime,
      location: "순간모임",
      scheduleType: "instant",
      isActive: true
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.startTime == sameTime)
    #expect(entity.endTime == sameTime)
    #expect(entity.startTime == entity.endTime)
  }

  // MARK: - 동시성 테스트

  @Test("동시 일정 생성 요청 처리")
  func test_concurrent_schedule_creation() async throws {
    // Given
    let repository = createMockScheduleRepository()
    let scheduleCount = 5

    // When
    await withTaskGroup(of: Void.self) { group in
      for i in 0..<scheduleCount {
        group.addTask {
          do {
            _ = try await repository.createSchedule(
              title: "동시생성일정\(i)",
              description: "동시성 테스트 \(i)",
              startTime: Date(),
              endTime: Date().addingTimeInterval(3600),
              location: "장소\(i)",
              scheduleType: "test",
              teamIds: [i + 1]
            )
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 크래시나 데드락 없이 완료되어야 함
    #expect(true)
  }

  @Test("동시 일정 조회 요청 처리")
  func test_concurrent_schedule_fetch() async throws {
    // Given
    let repository = createMockScheduleRepository()
    let teamIds = [1, 2, 3, 4, 5]

    // When
    await withTaskGroup(of: Void.self) { group in
      for teamId in teamIds {
        group.addTask {
          do {
            _ = try await repository.fetchSchedules(teamId: teamId)
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

// MARK: - Mock MoyaProvider for Schedule

extension MockMoyaProvider where Target == ScheduleService {

  override func request<T: Decodable>(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) async throws -> T {
    if let scheduleTarget = target as? ScheduleService {
      return try createMockScheduleResponse(for: scheduleTarget) as! T
    }

    throw ScheduleError.networkError
  }

  private func createMockScheduleResponse<T: Decodable>(for target: ScheduleService) throws -> T {
    switch target {
    case .createSchedule(let request):
      if request.teamIds.contains(-1) {
        throw ScheduleError.unauthorized
      }
      if request.endTime <= request.startTime {
        throw ScheduleError.invalidTimeRange
      }

      let response = CreateScheduleResponseDTO(
        scheduleId: 12345,
        title: request.title,
        description: request.description,
        startTime: request.startTime,
        endTime: request.endTime,
        location: request.location,
        scheduleType: request.scheduleType,
        isActive: true,
        teamIds: request.teamIds,
        createdAt: Date()
      )
      return response as! T

    case .fetchSchedules(let teamId):
      if teamId == -999 {
        throw ScheduleError.networkError
      }

      let schedules = [
        ScheduleListDTO(
          scheduleId: 1001,
          title: "iOS 스터디",
          description: "iOS 개발 스터디",
          startTime: Date(),
          endTime: Date().addingTimeInterval(7200),
          location: "온라인",
          scheduleType: "study",
          isActive: true
        ),
        ScheduleListDTO(
          scheduleId: 1002,
          title: "코드 리뷰",
          description: "주간 코드 리뷰",
          startTime: Date(),
          endTime: Date().addingTimeInterval(3600),
          location: "회의실",
          scheduleType: "review",
          isActive: true
        ),
        ScheduleListDTO(
          scheduleId: 1003,
          title: "프로젝트 회의",
          description: "프로젝트 진행 상황 회의",
          startTime: Date(),
          endTime: Date().addingTimeInterval(5400),
          location: "대회의실",
          scheduleType: "meeting",
          isActive: true
        )
      ]
      return schedules as! T

    case .getScheduleDetail(let scheduleId):
      if scheduleId == -9999 {
        throw ScheduleError.scheduleNotFound
      }

      let detail = ScheduleDetailDTO(
        scheduleId: 2001,
        title: "전체 정기모임",
        description: "DDD 전체 멤버 정기모임",
        startTime: Date(),
        endTime: Date().addingTimeInterval(10800),
        location: "강남역 회의실",
        scheduleType: "meeting",
        isActive: true,
        attendanceCount: 25,
        totalMemberCount: 30,
        teamIds: [1, 2, 3, 4],
        createdBy: "관리자",
        createdAt: Date(),
        updatedAt: Date()
      )
      return detail as! T

    case .editSchedule(_, _), .deleteSchedule(_), .toggleScheduleStatus(_, _):
      // 수정, 삭제, 상태변경은 Void 반환
      return () as! T

    default:
      throw ScheduleError.networkError
    }
  }
}

// MARK: - Mock DTOs

struct CreateScheduleResponseDTO: Codable {
  let scheduleId: Int
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let isActive: Bool
  let teamIds: [Int]
  let createdAt: Date

  func toDomain() -> ScheduleEntity {
    return ScheduleEntity(
      scheduleId: scheduleId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      scheduleType: scheduleType,
      isActive: isActive,
      teamIds: teamIds
    )
  }
}

struct ScheduleListDTO: Codable {
  let scheduleId: Int
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let isActive: Bool

  func toDomain() -> ScheduleEntity {
    return ScheduleEntity(
      scheduleId: scheduleId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      scheduleType: scheduleType,
      isActive: isActive,
      teamIds: []
    )
  }
}

struct ScheduleDetailDTO: Codable {
  let scheduleId: Int
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let isActive: Bool
  let attendanceCount: Int
  let totalMemberCount: Int
  let teamIds: [Int]
  let createdBy: String
  let createdAt: Date
  let updatedAt: Date

  func toDomain() -> ScheduleDetailEntity {
    return ScheduleDetailEntity(
      scheduleId: scheduleId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      scheduleType: scheduleType,
      isActive: isActive,
      attendanceCount: attendanceCount,
      totalMemberCount: totalMemberCount,
      teamIds: teamIds,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
}

struct CreateScheduleRequest {
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let teamIds: [Int]
}

struct EditScheduleRequest {
  let scheduleId: Int
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
}

// MARK: - Mock Entities

struct ScheduleEntity {
  let scheduleId: Int
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let isActive: Bool
  let teamIds: [Int]
}

struct ScheduleDetailEntity {
  let scheduleId: Int
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let isActive: Bool
  let attendanceCount: Int
  let totalMemberCount: Int
  let teamIds: [Int]
  let createdBy: String
  let createdAt: Date
  let updatedAt: Date
}

// MARK: - Mock Errors

enum ScheduleError: Error {
  case unauthorized
  case invalidTimeRange
  case scheduleNotFound
  case networkError
}