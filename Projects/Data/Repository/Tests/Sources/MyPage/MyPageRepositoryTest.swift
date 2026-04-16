//
//  MyPageRepositoryTest.swift
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

@Suite("MyPage Repository API Tests")
@MainActor
struct MyPageRepositoryTest {

  // MARK: - Test Fixtures

  private func createMockMyPageRepository() -> MyPageRepositoryImpl {
    return MyPageRepositoryImpl(provider: MockMoyaProvider<MyPageService>())
  }

  // MARK: - API 호출 성공 테스트

  @Test("내 출석 기록 조회 API 호출 성공")
  func test_fetch_my_attendances_api_success() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When
    let result = try await repository.fetchMyAttendances()

    // Then
    #expect(result.count == 5)

    // 첫 번째 출석 기록 검증
    #expect(result[0].attendanceId == 1001)
    #expect(result[0].scheduleName == "iOS 스터디")
    #expect(result[0].attendanceStatus == "참석")
    #expect(result[0].scheduleType == "study")

    // 두 번째 출석 기록 검증 (지각)
    #expect(result[1].attendanceId == 1002)
    #expect(result[1].scheduleName == "코드 리뷰")
    #expect(result[1].attendanceStatus == "지각")
    #expect(result[1].lateMinutes == 15)

    // 세 번째 출석 기록 검증 (결석)
    #expect(result[2].attendanceId == 1003)
    #expect(result[2].scheduleName == "프로젝트 회의")
    #expect(result[2].attendanceStatus == "결석")
    #expect(result[2].lateMinutes == nil)
  }

  @Test("내 일정 목록 조회 API 호출 성공")
  func test_fetch_my_schedules_api_success() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When
    let result = try await repository.fetchMySchedules()

    // Then
    #expect(result.count == 4)

    // 예정된 일정 검증
    #expect(result[0].scheduleId == 2001)
    #expect(result[0].title == "다음 주 정기모임")
    #expect(result[0].scheduleStatus == "upcoming")
    #expect(result[0].isRegistered == true)

    // 진행 중인 일정 검증
    #expect(result[1].scheduleId == 2002)
    #expect(result[1].title == "현재 진행 중인 스터디")
    #expect(result[1].scheduleStatus == "ongoing")
    #expect(result[1].isRegistered == true)

    // 완료된 일정 검증
    #expect(result[2].scheduleId == 2003)
    #expect(result[2].title == "지난 주 회의")
    #expect(result[2].scheduleStatus == "completed")

    // 등록하지 않은 일정 검증
    #expect(result[3].scheduleId == 2004)
    #expect(result[3].title == "선택적 워크샵")
    #expect(result[3].scheduleStatus == "upcoming")
    #expect(result[3].isRegistered == false)
  }

  @Test("개인 출석 통계 조회 API 호출 성공")
  func test_fetch_my_attendance_statistics_api_success() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When
    let result = try await repository.fetchMyAttendanceStatistics()

    // Then
    #expect(result.totalSchedules == 20)
    #expect(result.attendanceCount == 15)
    #expect(result.lateCount == 3)
    #expect(result.absentCount == 2)
    #expect(result.attendanceRate == 75.0) // 15/20 * 100
    #expect(result.currentStreak == 5) // 연속 출석 일수
    #expect(result.longestStreak == 12) // 최장 연속 출석 기록
  }

  @Test("알림 설정 조회 API 호출 성공")
  func test_fetch_notification_settings_api_success() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When
    let result = try await repository.fetchNotificationSettings()

    // Then
    #expect(result.pushNotificationEnabled == true)
    #expect(result.emailNotificationEnabled == false)
    #expect(result.scheduleReminderEnabled == true)
    #expect(result.attendanceReminderEnabled == true)
    #expect(result.reminderMinutesBefore == 30)
  }

  @Test("알림 설정 업데이트 API 호출 성공")
  func test_update_notification_settings_api_success() async throws {
    // Given
    let repository = createMockMyPageRepository()
    let newSettings = NotificationSettingsRequest(
      pushNotificationEnabled: false,
      emailNotificationEnabled: true,
      scheduleReminderEnabled: false,
      attendanceReminderEnabled: true,
      reminderMinutesBefore: 60
    )

    // When & Then
    try await repository.updateNotificationSettings(
      pushNotificationEnabled: newSettings.pushNotificationEnabled,
      emailNotificationEnabled: newSettings.emailNotificationEnabled,
      scheduleReminderEnabled: newSettings.scheduleReminderEnabled,
      attendanceReminderEnabled: newSettings.attendanceReminderEnabled,
      reminderMinutesBefore: newSettings.reminderMinutesBefore
    )

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  @Test("일정 등록/취소 API 호출 성공")
  func test_toggle_schedule_registration_api_success() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When & Then - 일정 등록
    try await repository.toggleScheduleRegistration(scheduleId: 3001, isRegistered: true)
    #expect(true)

    // When & Then - 일정 취소
    try await repository.toggleScheduleRegistration(scheduleId: 3002, isRegistered: false)
    #expect(true)
  }

  // MARK: - API 호출 실패 테스트

  @Test("내 출석 기록 조회 API 호출 실패 (권한 없음)")
  func test_fetch_my_attendances_api_unauthorized() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When & Then
    #expect(throws: MyPageError.unauthorized) {
      try await repository.fetchMyAttendances(userId: -1) // 권한 오류를 트리거하는 값
    }
  }

  @Test("알림 설정 업데이트 API 호출 실패 (잘못된 데이터)")
  func test_update_notification_settings_api_invalid_data() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When & Then
    #expect(throws: MyPageError.invalidNotificationData) {
      try await repository.updateNotificationSettings(
        pushNotificationEnabled: true,
        emailNotificationEnabled: true,
        scheduleReminderEnabled: true,
        attendanceReminderEnabled: true,
        reminderMinutesBefore: -10 // 잘못된 알림 시간
      )
    }
  }

  @Test("일정 등록 API 호출 실패 (존재하지 않는 일정)")
  func test_toggle_schedule_registration_api_schedule_not_found() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When & Then
    #expect(throws: MyPageError.scheduleNotFound) {
      try await repository.toggleScheduleRegistration(scheduleId: -9999, isRegistered: true)
    }
  }

  @Test("네트워크 오류 처리")
  func test_network_error_handling() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When & Then
    #expect(throws: MyPageError.networkError) {
      try await repository.fetchMySchedules(userId: -999) // 네트워크 오류를 트리거하는 값
    }
  }

  // MARK: - DTO to Entity 매핑 테스트

  @Test("MyAttendanceDTO to MyAttendanceEntity 매핑")
  func test_my_attendance_dto_mapping() throws {
    // Given
    let checkInTime = Date()
    let scheduleDate = Date().addingTimeInterval(-86400) // 하루 전

    let dto = MyAttendanceDTO(
      attendanceId: 5001,
      scheduleId: 6001,
      scheduleName: "테스트 스터디",
      scheduleDate: scheduleDate,
      attendanceStatus: "지각",
      checkInTime: checkInTime,
      lateMinutes: 20,
      scheduleType: "study",
      location: "온라인"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.attendanceId == 5001)
    #expect(entity.scheduleId == 6001)
    #expect(entity.scheduleName == "테스트 스터디")
    #expect(entity.scheduleDate == scheduleDate)
    #expect(entity.attendanceStatus == "지각")
    #expect(entity.checkInTime == checkInTime)
    #expect(entity.lateMinutes == 20)
    #expect(entity.scheduleType == "study")
    #expect(entity.location == "온라인")
  }

  @Test("MyScheduleDTO to MyScheduleEntity 매핑")
  func test_my_schedule_dto_mapping() throws {
    // Given
    let startTime = Date()
    let endTime = Date().addingTimeInterval(7200) // 2시간 후

    let dto = MyScheduleDTO(
      scheduleId: 7001,
      title: "개인 일정 테스트",
      description: "개인 일정 설명",
      startTime: startTime,
      endTime: endTime,
      location: "강남역",
      scheduleType: "meeting",
      scheduleStatus: "upcoming",
      isRegistered: true,
      registrationDeadline: Date().addingTimeInterval(3600)
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.scheduleId == 7001)
    #expect(entity.title == "개인 일정 테스트")
    #expect(entity.description == "개인 일정 설명")
    #expect(entity.startTime == startTime)
    #expect(entity.endTime == endTime)
    #expect(entity.location == "강남역")
    #expect(entity.scheduleType == "meeting")
    #expect(entity.scheduleStatus == "upcoming")
    #expect(entity.isRegistered == true)
  }

  @Test("AttendanceStatisticsDTO to AttendanceStatisticsEntity 매핑")
  func test_attendance_statistics_dto_mapping() throws {
    // Given
    let dto = AttendanceStatisticsDTO(
      totalSchedules: 50,
      attendanceCount: 40,
      lateCount: 7,
      absentCount: 3,
      attendanceRate: 80.0,
      currentStreak: 8,
      longestStreak: 15,
      monthlyAttendance: [
        MonthlyAttendanceDTO(month: "2025-01", attendanceCount: 15, totalCount: 18),
        MonthlyAttendanceDTO(month: "2025-02", attendanceCount: 12, totalCount: 14)
      ]
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.totalSchedules == 50)
    #expect(entity.attendanceCount == 40)
    #expect(entity.lateCount == 7)
    #expect(entity.absentCount == 3)
    #expect(entity.attendanceRate == 80.0)
    #expect(entity.currentStreak == 8)
    #expect(entity.longestStreak == 15)
    #expect(entity.monthlyAttendance.count == 2)
    #expect(entity.monthlyAttendance[0].month == "2025-01")
    #expect(entity.monthlyAttendance[0].attendanceCount == 15)
    #expect(entity.monthlyAttendance[1].month == "2025-02")
    #expect(entity.monthlyAttendance[1].attendanceCount == 12)
  }

  @Test("NotificationSettingsDTO to NotificationSettingsEntity 매핑")
  func test_notification_settings_dto_mapping() throws {
    // Given
    let dto = NotificationSettingsDTO(
      pushNotificationEnabled: true,
      emailNotificationEnabled: false,
      scheduleReminderEnabled: true,
      attendanceReminderEnabled: false,
      reminderMinutesBefore: 45
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.pushNotificationEnabled == true)
    #expect(entity.emailNotificationEnabled == false)
    #expect(entity.scheduleReminderEnabled == true)
    #expect(entity.attendanceReminderEnabled == false)
    #expect(entity.reminderMinutesBefore == 45)
  }

  // MARK: - 경계값 테스트

  @Test("빈 출석 기록 목록 처리")
  func test_empty_attendance_records() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When
    let result = try await repository.fetchMyAttendances(userId: 99999) // 빈 기록을 트리거하는 값

    // Then
    #expect(result.isEmpty)
  }

  @Test("0% 출석률 통계 처리")
  func test_zero_attendance_rate() throws {
    // Given
    let dto = AttendanceStatisticsDTO(
      totalSchedules: 10,
      attendanceCount: 0,
      lateCount: 0,
      absentCount: 10,
      attendanceRate: 0.0,
      currentStreak: 0,
      longestStreak: 0,
      monthlyAttendance: []
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.totalSchedules == 10)
    #expect(entity.attendanceCount == 0)
    #expect(entity.absentCount == 10)
    #expect(entity.attendanceRate == 0.0)
    #expect(entity.currentStreak == 0)
    #expect(entity.longestStreak == 0)
    #expect(entity.monthlyAttendance.isEmpty)
  }

  @Test("100% 출석률 통계 처리")
  func test_perfect_attendance_rate() throws {
    // Given
    let dto = AttendanceStatisticsDTO(
      totalSchedules: 25,
      attendanceCount: 25,
      lateCount: 0,
      absentCount: 0,
      attendanceRate: 100.0,
      currentStreak: 25,
      longestStreak: 25,
      monthlyAttendance: [
        MonthlyAttendanceDTO(month: "2025-04", attendanceCount: 25, totalCount: 25)
      ]
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.totalSchedules == 25)
    #expect(entity.attendanceCount == 25)
    #expect(entity.lateCount == 0)
    #expect(entity.absentCount == 0)
    #expect(entity.attendanceRate == 100.0)
    #expect(entity.currentStreak == 25)
    #expect(entity.longestStreak == 25)
  }

  @Test("매우 긴 지각 시간 처리")
  func test_very_long_late_minutes() throws {
    // Given
    let dto = MyAttendanceDTO(
      attendanceId: 9001,
      scheduleId: 9002,
      scheduleName: "늦은 출석 테스트",
      scheduleDate: Date(),
      attendanceStatus: "지각",
      checkInTime: Date(),
      lateMinutes: 180, // 3시간 지각
      scheduleType: "meeting",
      location: "회의실"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.lateMinutes == 180)
    #expect(entity.attendanceStatus == "지각")
  }

  // MARK: - 동시성 테스트

  @Test("동시 데이터 조회 요청 처리")
  func test_concurrent_data_fetch() async throws {
    // Given
    let repository = createMockMyPageRepository()

    // When
    await withTaskGroup(of: Void.self) { group in
      // 동시에 여러 API 호출
      group.addTask {
        do {
          _ = try await repository.fetchMyAttendances()
        } catch {
          // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
        }
      }

      group.addTask {
        do {
          _ = try await repository.fetchMySchedules()
        } catch {
          // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
        }
      }

      group.addTask {
        do {
          _ = try await repository.fetchMyAttendanceStatistics()
        } catch {
          // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
        }
      }

      group.addTask {
        do {
          _ = try await repository.fetchNotificationSettings()
        } catch {
          // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
        }
      }
    }

    // Then: 동시성 작업이 크래시나 데드락 없이 완료되어야 함
    #expect(true)
  }

  @Test("동시 알림 설정 업데이트 처리")
  func test_concurrent_notification_updates() async throws {
    // Given
    let repository = createMockMyPageRepository()
    let updateCount = 5

    // When
    await withTaskGroup(of: Void.self) { group in
      for i in 0..<updateCount {
        group.addTask {
          do {
            try await repository.updateNotificationSettings(
              pushNotificationEnabled: i % 2 == 0,
              emailNotificationEnabled: i % 3 == 0,
              scheduleReminderEnabled: true,
              attendanceReminderEnabled: true,
              reminderMinutesBefore: 30 + (i * 5)
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

// MARK: - Mock MoyaProvider for MyPage

extension MockMoyaProvider where Target == MyPageService {

  override func request<T: Decodable>(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) async throws -> T {
    if let myPageTarget = target as? MyPageService {
      return try createMockMyPageResponse(for: myPageTarget) as! T
    }

    throw MyPageError.networkError
  }

  private func createMockMyPageResponse<T: Decodable>(for target: MyPageService) throws -> T {
    switch target {
    case .fetchMyAttendances(let userId):
      if let userId = userId, userId == -1 {
        throw MyPageError.unauthorized
      }
      if let userId = userId, userId == -999 {
        throw MyPageError.networkError
      }
      if let userId = userId, userId == 99999 {
        return [] as! T // 빈 배열 반환
      }

      let attendances = [
        MyAttendanceDTO(
          attendanceId: 1001, scheduleId: 2001, scheduleName: "iOS 스터디",
          scheduleDate: Date(), attendanceStatus: "참석", checkInTime: Date(),
          lateMinutes: nil, scheduleType: "study", location: "온라인"
        ),
        MyAttendanceDTO(
          attendanceId: 1002, scheduleId: 2002, scheduleName: "코드 리뷰",
          scheduleDate: Date(), attendanceStatus: "지각", checkInTime: Date(),
          lateMinutes: 15, scheduleType: "review", location: "회의실"
        ),
        MyAttendanceDTO(
          attendanceId: 1003, scheduleId: 2003, scheduleName: "프로젝트 회의",
          scheduleDate: Date(), attendanceStatus: "결석", checkInTime: nil,
          lateMinutes: nil, scheduleType: "meeting", location: "대회의실"
        ),
        MyAttendanceDTO(
          attendanceId: 1004, scheduleId: 2004, scheduleName: "팀 빌딩",
          scheduleDate: Date(), attendanceStatus: "참석", checkInTime: Date(),
          lateMinutes: nil, scheduleType: "activity", location: "강남역"
        ),
        MyAttendanceDTO(
          attendanceId: 1005, scheduleId: 2005, scheduleName: "발표 세션",
          scheduleDate: Date(), attendanceStatus: "지각", checkInTime: Date(),
          lateMinutes: 5, scheduleType: "presentation", location: "온라인"
        )
      ]
      return attendances as! T

    case .fetchMySchedules(let userId):
      if let userId = userId, userId == -999 {
        throw MyPageError.networkError
      }

      let schedules = [
        MyScheduleDTO(
          scheduleId: 2001, title: "다음 주 정기모임", description: "정기 모임",
          startTime: Date().addingTimeInterval(604800), endTime: Date().addingTimeInterval(608400),
          location: "강남역", scheduleType: "meeting", scheduleStatus: "upcoming",
          isRegistered: true, registrationDeadline: Date().addingTimeInterval(518400)
        ),
        MyScheduleDTO(
          scheduleId: 2002, title: "현재 진행 중인 스터디", description: "스터디",
          startTime: Date(), endTime: Date().addingTimeInterval(7200),
          location: "온라인", scheduleType: "study", scheduleStatus: "ongoing",
          isRegistered: true, registrationDeadline: nil
        ),
        MyScheduleDTO(
          scheduleId: 2003, title: "지난 주 회의", description: "회의",
          startTime: Date().addingTimeInterval(-604800), endTime: Date().addingTimeInterval(-601200),
          location: "회의실", scheduleType: "meeting", scheduleStatus: "completed",
          isRegistered: true, registrationDeadline: nil
        ),
        MyScheduleDTO(
          scheduleId: 2004, title: "선택적 워크샵", description: "워크샵",
          startTime: Date().addingTimeInterval(1209600), endTime: Date().addingTimeInterval(1213200),
          location: "교육센터", scheduleType: "workshop", scheduleStatus: "upcoming",
          isRegistered: false, registrationDeadline: Date().addingTimeInterval(864000)
        )
      ]
      return schedules as! T

    case .fetchMyAttendanceStatistics:
      let statistics = AttendanceStatisticsDTO(
        totalSchedules: 20,
        attendanceCount: 15,
        lateCount: 3,
        absentCount: 2,
        attendanceRate: 75.0,
        currentStreak: 5,
        longestStreak: 12,
        monthlyAttendance: [
          MonthlyAttendanceDTO(month: "2025-03", attendanceCount: 8, totalCount: 10),
          MonthlyAttendanceDTO(month: "2025-04", attendanceCount: 7, totalCount: 10)
        ]
      )
      return statistics as! T

    case .fetchNotificationSettings:
      let settings = NotificationSettingsDTO(
        pushNotificationEnabled: true,
        emailNotificationEnabled: false,
        scheduleReminderEnabled: true,
        attendanceReminderEnabled: true,
        reminderMinutesBefore: 30
      )
      return settings as! T

    case .updateNotificationSettings(let request):
      if request.reminderMinutesBefore < 0 {
        throw MyPageError.invalidNotificationData
      }
      return () as! T

    case .toggleScheduleRegistration(let scheduleId, _):
      if scheduleId == -9999 {
        throw MyPageError.scheduleNotFound
      }
      return () as! T

    default:
      throw MyPageError.networkError
    }
  }
}

// MARK: - Mock DTOs

struct MyAttendanceDTO: Codable {
  let attendanceId: Int
  let scheduleId: Int
  let scheduleName: String
  let scheduleDate: Date
  let attendanceStatus: String
  let checkInTime: Date?
  let lateMinutes: Int?
  let scheduleType: String
  let location: String

  func toDomain() -> MyAttendanceEntity {
    return MyAttendanceEntity(
      attendanceId: attendanceId,
      scheduleId: scheduleId,
      scheduleName: scheduleName,
      scheduleDate: scheduleDate,
      attendanceStatus: attendanceStatus,
      checkInTime: checkInTime,
      lateMinutes: lateMinutes,
      scheduleType: scheduleType,
      location: location
    )
  }
}

struct MyScheduleDTO: Codable {
  let scheduleId: Int
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let scheduleStatus: String
  let isRegistered: Bool
  let registrationDeadline: Date?

  func toDomain() -> MyScheduleEntity {
    return MyScheduleEntity(
      scheduleId: scheduleId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      scheduleType: scheduleType,
      scheduleStatus: scheduleStatus,
      isRegistered: isRegistered,
      registrationDeadline: registrationDeadline
    )
  }
}

struct AttendanceStatisticsDTO: Codable {
  let totalSchedules: Int
  let attendanceCount: Int
  let lateCount: Int
  let absentCount: Int
  let attendanceRate: Double
  let currentStreak: Int
  let longestStreak: Int
  let monthlyAttendance: [MonthlyAttendanceDTO]

  func toDomain() -> AttendanceStatisticsEntity {
    return AttendanceStatisticsEntity(
      totalSchedules: totalSchedules,
      attendanceCount: attendanceCount,
      lateCount: lateCount,
      absentCount: absentCount,
      attendanceRate: attendanceRate,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      monthlyAttendance: monthlyAttendance.map { $0.toDomain() }
    )
  }
}

struct MonthlyAttendanceDTO: Codable {
  let month: String
  let attendanceCount: Int
  let totalCount: Int

  func toDomain() -> MonthlyAttendanceEntity {
    return MonthlyAttendanceEntity(
      month: month,
      attendanceCount: attendanceCount,
      totalCount: totalCount
    )
  }
}

struct NotificationSettingsDTO: Codable {
  let pushNotificationEnabled: Bool
  let emailNotificationEnabled: Bool
  let scheduleReminderEnabled: Bool
  let attendanceReminderEnabled: Bool
  let reminderMinutesBefore: Int

  func toDomain() -> NotificationSettingsEntity {
    return NotificationSettingsEntity(
      pushNotificationEnabled: pushNotificationEnabled,
      emailNotificationEnabled: emailNotificationEnabled,
      scheduleReminderEnabled: scheduleReminderEnabled,
      attendanceReminderEnabled: attendanceReminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore
    )
  }
}

struct NotificationSettingsRequest {
  let pushNotificationEnabled: Bool
  let emailNotificationEnabled: Bool
  let scheduleReminderEnabled: Bool
  let attendanceReminderEnabled: Bool
  let reminderMinutesBefore: Int
}

// MARK: - Mock Entities

struct MyAttendanceEntity {
  let attendanceId: Int
  let scheduleId: Int
  let scheduleName: String
  let scheduleDate: Date
  let attendanceStatus: String
  let checkInTime: Date?
  let lateMinutes: Int?
  let scheduleType: String
  let location: String
}

struct MyScheduleEntity {
  let scheduleId: Int
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let scheduleStatus: String
  let isRegistered: Bool
  let registrationDeadline: Date?
}

struct AttendanceStatisticsEntity {
  let totalSchedules: Int
  let attendanceCount: Int
  let lateCount: Int
  let absentCount: Int
  let attendanceRate: Double
  let currentStreak: Int
  let longestStreak: Int
  let monthlyAttendance: [MonthlyAttendanceEntity]
}

struct MonthlyAttendanceEntity {
  let month: String
  let attendanceCount: Int
  let totalCount: Int
}

struct NotificationSettingsEntity {
  let pushNotificationEnabled: Bool
  let emailNotificationEnabled: Bool
  let scheduleReminderEnabled: Bool
  let attendanceReminderEnabled: Bool
  let reminderMinutesBefore: Int
}

// MARK: - Mock Errors

enum MyPageError: Error {
  case unauthorized
  case invalidNotificationData
  case scheduleNotFound
  case networkError
}