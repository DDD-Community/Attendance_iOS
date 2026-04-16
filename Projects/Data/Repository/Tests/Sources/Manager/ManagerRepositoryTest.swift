//
//  ManagerRepositoryTest.swift
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

@Suite("Manager Repository API Tests")
@MainActor
struct ManagerRepositoryTest {

  // MARK: - Test Fixtures

  private func createMockManagerRepository() -> ManagerRepositoryImpl {
    return ManagerRepositoryImpl(provider: MockMoyaProvider<ManagerService>())
  }

  // MARK: - API 호출 성공 테스트

  @Test("전체 출석 통계 관리 API 호출 성공")
  func test_fetch_overall_attendance_statistics_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When
    let result = try await repository.fetchOverallAttendanceStatistics()

    // Then
    #expect(result.totalMembers == 30)
    #expect(result.totalSchedules == 50)
    #expect(result.overallAttendanceRate == 85.5)
    #expect(result.averageLateMinutes == 12.3)
    #expect(result.topPerformingTeams.count == 3)
    #expect(result.topPerformingTeams[0].teamName == "iOS팀")
    #expect(result.topPerformingTeams[0].attendanceRate == 92.0)
    #expect(result.topPerformingTeams[1].teamName == "백엔드팀")
    #expect(result.topPerformingTeams[1].attendanceRate == 88.5)
    #expect(result.monthlyTrends.count == 6) // 최근 6개월
  }

  @Test("팀원 관리 - 전체 팀원 목록 조회 API 호출 성공")
  func test_fetch_all_members_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When
    let result = try await repository.fetchAllMembers()

    // Then
    #expect(result.count == 5)

    // 첫 번째 멤버 검증 (매니저)
    #expect(result[0].userId == 1001)
    #expect(result[0].name == "홍길동")
    #expect(result[0].email == "hong@ddd.com")
    #expect(result[0].role == .manager)
    #expect(result[0].teamName == "iOS팀")
    #expect(result[0].generation == "10기")
    #expect(result[0].attendanceRate == 95.0)
    #expect(result[0].isActive == true)

    // 두 번째 멤버 검증 (일반 멤버)
    #expect(result[1].userId == 1002)
    #expect(result[1].name == "김철수")
    #expect(result[1].role == .member)
    #expect(result[1].teamName == "Android팀")
    #expect(result[1].attendanceRate == 88.0)
  }

  @Test("팀원 권한 변경 API 호출 성공")
  func test_update_member_role_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When & Then - Member를 Manager로 승격
    try await repository.updateMemberRole(userId: 1002, newRole: .manager)
    #expect(true)

    // When & Then - Manager를 Member로 강등
    try await repository.updateMemberRole(userId: 1001, newRole: .member)
    #expect(true)
  }

  @Test("팀원 추가 API 호출 성공")
  func test_add_new_member_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()
    let newMemberRequest = AddMemberRequest(
      name: "박영희",
      email: "park@ddd.com",
      teamId: 1,
      partId: 1,
      generation: "10기",
      role: .member,
      inviteCode: "DDD2025MANAGER"
    )

    // When
    let result = try await repository.addNewMember(
      name: newMemberRequest.name,
      email: newMemberRequest.email,
      teamId: newMemberRequest.teamId,
      partId: newMemberRequest.partId,
      generation: newMemberRequest.generation,
      role: newMemberRequest.role,
      inviteCode: newMemberRequest.inviteCode
    )

    // Then
    #expect(result.userId == 2001)
    #expect(result.name == "박영희")
    #expect(result.email == "park@ddd.com")
    #expect(result.teamName == "iOS팀")
    #expect(result.role == .member)
    #expect(result.generation == "10기")
    #expect(result.isSuccessful == true)
    #expect(result.message == "새 멤버가 성공적으로 추가되었습니다")
  }

  @Test("팀원 제거 API 호출 성공")
  func test_remove_member_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When & Then
    try await repository.removeMember(userId: 1005, reason: "규정 위반으로 인한 제명")
    #expect(true)
  }

  @Test("시스템 설정 조회 API 호출 성공")
  func test_fetch_system_settings_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When
    let result = try await repository.fetchSystemSettings()

    // Then
    #expect(result.attendanceSettings.lateThresholdMinutes == 10)
    #expect(result.attendanceSettings.absentThresholdMinutes == 30)
    #expect(result.attendanceSettings.autoMarkAbsentEnabled == true)
    #expect(result.notificationSettings.reminderBeforeMinutes == 30)
    #expect(result.notificationSettings.dailyReportEnabled == true)
    #expect(result.notificationSettings.weeklyReportEnabled == true)
    #expect(result.scheduleSettings.maxSchedulesPerDay == 3)
    #expect(result.scheduleSettings.advanceRegistrationDays == 7)
    #expect(result.scheduleSettings.cancellationDeadlineHours == 24)
  }

  @Test("시스템 설정 업데이트 API 호출 성공")
  func test_update_system_settings_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()
    let updateRequest = SystemSettingsUpdateRequest(
      attendanceSettings: AttendanceSettingsRequest(
        lateThresholdMinutes: 15,
        absentThresholdMinutes: 45,
        autoMarkAbsentEnabled: false
      ),
      notificationSettings: NotificationSettingsRequest(
        reminderBeforeMinutes: 60,
        dailyReportEnabled: false,
        weeklyReportEnabled: true
      ),
      scheduleSettings: ScheduleSettingsRequest(
        maxSchedulesPerDay: 2,
        advanceRegistrationDays: 14,
        cancellationDeadlineHours: 48
      )
    )

    // When & Then
    try await repository.updateSystemSettings(
      attendanceSettings: updateRequest.attendanceSettings,
      notificationSettings: updateRequest.notificationSettings,
      scheduleSettings: updateRequest.scheduleSettings
    )

    #expect(true)
  }

  @Test("일정 일괄 관리 - 다중 일정 생성 API 호출 성공")
  func test_create_bulk_schedules_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()
    let bulkSchedules = [
      BulkScheduleRequest(
        title: "정기모임 1주차",
        description: "첫 번째 정기모임",
        startTime: Date(),
        endTime: Date().addingTimeInterval(7200),
        location: "강남역",
        scheduleType: "meeting",
        targetTeamIds: [1, 2]
      ),
      BulkScheduleRequest(
        title: "정기모임 2주차",
        description: "두 번째 정기모임",
        startTime: Date().addingTimeInterval(604800),
        endTime: Date().addingTimeInterval(611400),
        location: "역삼역",
        scheduleType: "meeting",
        targetTeamIds: [1, 2, 3]
      )
    ]

    // When
    let result = try await repository.createBulkSchedules(schedules: bulkSchedules)

    // Then
    #expect(result.createdSchedules.count == 2)
    #expect(result.successCount == 2)
    #expect(result.failureCount == 0)
    #expect(result.createdSchedules[0].scheduleId == 3001)
    #expect(result.createdSchedules[0].title == "정기모임 1주차")
    #expect(result.createdSchedules[1].scheduleId == 3002)
    #expect(result.createdSchedules[1].title == "정기모임 2주차")
    #expect(result.totalAffectedMembers == 45)
  }

  @Test("관리자 대시보드 데이터 조회 API 호출 성공")
  func test_fetch_dashboard_data_api_success() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When
    let result = try await repository.fetchDashboardData()

    // Then
    #expect(result.todayAttendanceCount == 25)
    #expect(result.todayScheduleCount == 3)
    #expect(result.pendingApprovals == 8)
    #expect(result.recentActivities.count == 10)
    #expect(result.upcomingDeadlines.count == 5)
    #expect(result.teamPerformance.count == 4)

    // 최근 활동 검증
    #expect(result.recentActivities[0].type == "attendance")
    #expect(result.recentActivities[0].description == "홍길동님이 출석했습니다")
    #expect(result.recentActivities[0].timestamp != nil)

    // 예정된 마감일 검증
    #expect(result.upcomingDeadlines[0].type == "schedule_registration")
    #expect(result.upcomingDeadlines[0].description == "정기모임 등록 마감")
    #expect(result.upcomingDeadlines[0].deadline != nil)
  }

  // MARK: - API 호출 실패 테스트

  @Test("팀원 권한 변경 API 호출 실패 (권한 없음)")
  func test_update_member_role_api_unauthorized() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When & Then
    #expect(throws: ManagerError.unauthorized) {
      try await repository.updateMemberRole(userId: -1, newRole: .manager) // 권한 오류를 트리거하는 값
    }
  }

  @Test("팀원 추가 API 호출 실패 (중복 이메일)")
  func test_add_new_member_api_duplicate_email() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When & Then
    #expect(throws: ManagerError.duplicateEmail) {
      try await repository.addNewMember(
        name: "중복사용자",
        email: "duplicate@ddd.com", // 중복 이메일로 오류 트리거
        teamId: 1,
        partId: 1,
        generation: "10기",
        role: .member,
        inviteCode: "DDD2025MANAGER"
      )
    }
  }

  @Test("팀원 제거 API 호출 실패 (존재하지 않는 사용자)")
  func test_remove_member_api_user_not_found() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When & Then
    #expect(throws: ManagerError.memberNotFound) {
      try await repository.removeMember(userId: -9999, reason: "테스트")
    }
  }

  @Test("시스템 설정 업데이트 API 호출 실패 (잘못된 설정값)")
  func test_update_system_settings_api_invalid_settings() async throws {
    // Given
    let repository = createMockManagerRepository()
    let invalidRequest = SystemSettingsUpdateRequest(
      attendanceSettings: AttendanceSettingsRequest(
        lateThresholdMinutes: -10, // 잘못된 값
        absentThresholdMinutes: 30,
        autoMarkAbsentEnabled: true
      ),
      notificationSettings: NotificationSettingsRequest(
        reminderBeforeMinutes: 30,
        dailyReportEnabled: true,
        weeklyReportEnabled: true
      ),
      scheduleSettings: ScheduleSettingsRequest(
        maxSchedulesPerDay: 5,
        advanceRegistrationDays: 7,
        cancellationDeadlineHours: 24
      )
    )

    // When & Then
    #expect(throws: ManagerError.invalidSettingsValue) {
      try await repository.updateSystemSettings(
        attendanceSettings: invalidRequest.attendanceSettings,
        notificationSettings: invalidRequest.notificationSettings,
        scheduleSettings: invalidRequest.scheduleSettings
      )
    }
  }

  @Test("네트워크 오류 처리")
  func test_network_error_handling() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When & Then
    #expect(throws: ManagerError.networkError) {
      try await repository.fetchAllMembers(teamId: -999) // 네트워크 오류를 트리거하는 값
    }
  }

  // MARK: - DTO to Entity 매핑 테스트

  @Test("OverallAttendanceStatisticsDTO to OverallAttendanceStatisticsEntity 매핑")
  func test_overall_attendance_statistics_dto_mapping() throws {
    // Given
    let topTeams = [
      TopPerformingTeamDTO(teamId: 1, teamName: "최고팀", attendanceRate: 98.5, memberCount: 8),
      TopPerformingTeamDTO(teamId: 2, teamName: "우수팀", attendanceRate: 95.2, memberCount: 6)
    ]

    let monthlyTrends = [
      MonthlyTrendDTO(month: "2025-03", attendanceRate: 87.5, totalSchedules: 20),
      MonthlyTrendDTO(month: "2025-04", attendanceRate: 89.2, totalSchedules: 18)
    ]

    let dto = OverallAttendanceStatisticsDTO(
      totalMembers: 50,
      totalSchedules: 100,
      overallAttendanceRate: 90.5,
      averageLateMinutes: 8.7,
      topPerformingTeams: topTeams,
      monthlyTrends: monthlyTrends,
      lastUpdated: Date()
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.totalMembers == 50)
    #expect(entity.totalSchedules == 100)
    #expect(entity.overallAttendanceRate == 90.5)
    #expect(entity.averageLateMinutes == 8.7)
    #expect(entity.topPerformingTeams.count == 2)
    #expect(entity.topPerformingTeams[0].teamName == "최고팀")
    #expect(entity.topPerformingTeams[0].attendanceRate == 98.5)
    #expect(entity.monthlyTrends.count == 2)
    #expect(entity.monthlyTrends[0].month == "2025-03")
    #expect(entity.monthlyTrends[0].attendanceRate == 87.5)
  }

  @Test("MemberInfoDTO to MemberInfoEntity 매핑")
  func test_member_info_dto_mapping() throws {
    // Given
    let joinDate = Date()
    let lastAttendance = Date().addingTimeInterval(-86400)

    let dto = MemberInfoDTO(
      userId: 12345,
      name: "테스트멤버",
      email: "test@ddd.com",
      role: "manager",
      teamName: "테스트팀",
      partName: "테스트개발자",
      generation: "테스트기",
      attendanceRate: 92.5,
      lateCount: 3,
      absentCount: 2,
      isActive: true,
      joinDate: joinDate,
      lastAttendance: lastAttendance
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.userId == 12345)
    #expect(entity.name == "테스트멤버")
    #expect(entity.email == "test@ddd.com")
    #expect(entity.role == .manager)
    #expect(entity.teamName == "테스트팀")
    #expect(entity.partName == "테스트개발자")
    #expect(entity.generation == "테스트기")
    #expect(entity.attendanceRate == 92.5)
    #expect(entity.lateCount == 3)
    #expect(entity.absentCount == 2)
    #expect(entity.isActive == true)
    #expect(entity.joinDate == joinDate)
    #expect(entity.lastAttendance == lastAttendance)
  }

  @Test("SystemSettingsDTO to SystemSettingsEntity 매핑")
  func test_system_settings_dto_mapping() throws {
    // Given
    let attendanceSettings = AttendanceSettingsDTO(
      lateThresholdMinutes: 15,
      absentThresholdMinutes: 45,
      autoMarkAbsentEnabled: false
    )

    let notificationSettings = NotificationSettingsDTO(
      reminderBeforeMinutes: 60,
      dailyReportEnabled: false,
      weeklyReportEnabled: true
    )

    let scheduleSettings = ScheduleSettingsDTO(
      maxSchedulesPerDay: 2,
      advanceRegistrationDays: 14,
      cancellationDeadlineHours: 48
    )

    let dto = SystemSettingsDTO(
      attendanceSettings: attendanceSettings,
      notificationSettings: notificationSettings,
      scheduleSettings: scheduleSettings,
      lastModified: Date(),
      modifiedBy: "시스템관리자"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.attendanceSettings.lateThresholdMinutes == 15)
    #expect(entity.attendanceSettings.absentThresholdMinutes == 45)
    #expect(entity.attendanceSettings.autoMarkAbsentEnabled == false)
    #expect(entity.notificationSettings.reminderBeforeMinutes == 60)
    #expect(entity.notificationSettings.dailyReportEnabled == false)
    #expect(entity.notificationSettings.weeklyReportEnabled == true)
    #expect(entity.scheduleSettings.maxSchedulesPerDay == 2)
    #expect(entity.scheduleSettings.advanceRegistrationDays == 14)
    #expect(entity.scheduleSettings.cancellationDeadlineHours == 48)
  }

  @Test("BulkScheduleCreationResponseDTO to BulkScheduleCreationEntity 매핑")
  func test_bulk_schedule_creation_response_dto_mapping() throws {
    // Given
    let createdSchedules = [
      CreatedScheduleDTO(scheduleId: 4001, title: "생성된일정1", teamIds: [1, 2]),
      CreatedScheduleDTO(scheduleId: 4002, title: "생성된일정2", teamIds: [2, 3])
    ]

    let failedSchedules = [
      FailedScheduleDTO(title: "실패한일정", reason: "시간 중복", errorCode: "TIME_CONFLICT")
    ]

    let dto = BulkScheduleCreationResponseDTO(
      createdSchedules: createdSchedules,
      failedSchedules: failedSchedules,
      successCount: 2,
      failureCount: 1,
      totalAffectedMembers: 35,
      executionTime: 1.5
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.createdSchedules.count == 2)
    #expect(entity.failedSchedules.count == 1)
    #expect(entity.successCount == 2)
    #expect(entity.failureCount == 1)
    #expect(entity.createdSchedules[0].scheduleId == 4001)
    #expect(entity.createdSchedules[0].title == "생성된일정1")
    #expect(entity.failedSchedules[0].title == "실패한일정")
    #expect(entity.failedSchedules[0].reason == "시간 중복")
    #expect(entity.totalAffectedMembers == 35)
    #expect(entity.executionTime == 1.5)
  }

  @Test("DashboardDataDTO to DashboardDataEntity 매핑")
  func test_dashboard_data_dto_mapping() throws {
    // Given
    let recentActivities = [
      DashboardActivityDTO(
        type: "attendance",
        description: "새 출석 기록",
        userId: 123,
        userName: "활동사용자",
        timestamp: Date()
      )
    ]

    let upcomingDeadlines = [
      DashboardDeadlineDTO(
        type: "schedule_deadline",
        description: "일정 등록 마감",
        deadline: Date().addingTimeInterval(3600),
        priority: "high"
      )
    ]

    let teamPerformance = [
      TeamPerformanceDTO(
        teamId: 1,
        teamName: "성과팀",
        attendanceRate: 94.5,
        averageScore: 4.2,
        memberCount: 8
      )
    ]

    let dto = DashboardDataDTO(
      todayAttendanceCount: 28,
      todayScheduleCount: 4,
      pendingApprovals: 12,
      recentActivities: recentActivities,
      upcomingDeadlines: upcomingDeadlines,
      teamPerformance: teamPerformance,
      lastRefreshed: Date()
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.todayAttendanceCount == 28)
    #expect(entity.todayScheduleCount == 4)
    #expect(entity.pendingApprovals == 12)
    #expect(entity.recentActivities.count == 1)
    #expect(entity.recentActivities[0].type == "attendance")
    #expect(entity.recentActivities[0].description == "새 출석 기록")
    #expect(entity.upcomingDeadlines.count == 1)
    #expect(entity.upcomingDeadlines[0].type == "schedule_deadline")
    #expect(entity.teamPerformance.count == 1)
    #expect(entity.teamPerformance[0].teamName == "성과팀")
    #expect(entity.teamPerformance[0].attendanceRate == 94.5)
  }

  // MARK: - 경계값 테스트

  @Test("빈 팀원 목록 처리")
  func test_empty_member_list() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When
    let result = try await repository.fetchAllMembers(teamId: 99999) // 빈 목록을 반환하는 특수 값

    // Then
    #expect(result.isEmpty)
  }

  @Test("0% 출석률을 가진 팀 처리")
  func test_zero_attendance_rate_team() throws {
    // Given
    let dto = TopPerformingTeamDTO(
      teamId: 999,
      teamName: "저조한팀",
      attendanceRate: 0.0,
      memberCount: 5
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.attendanceRate == 0.0)
    #expect(entity.teamName == "저조한팀")
    #expect(entity.memberCount == 5)
  }

  @Test("최대치 설정값 처리")
  func test_maximum_system_settings() throws {
    // Given
    let dto = SystemSettingsDTO(
      attendanceSettings: AttendanceSettingsDTO(
        lateThresholdMinutes: 120,
        absentThresholdMinutes: 300,
        autoMarkAbsentEnabled: true
      ),
      notificationSettings: NotificationSettingsDTO(
        reminderBeforeMinutes: 1440, // 24시간
        dailyReportEnabled: true,
        weeklyReportEnabled: true
      ),
      scheduleSettings: ScheduleSettingsDTO(
        maxSchedulesPerDay: 10,
        advanceRegistrationDays: 30,
        cancellationDeadlineHours: 168 // 1주일
      ),
      lastModified: Date(),
      modifiedBy: "최고관리자"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.attendanceSettings.lateThresholdMinutes == 120)
    #expect(entity.attendanceSettings.absentThresholdMinutes == 300)
    #expect(entity.notificationSettings.reminderBeforeMinutes == 1440)
    #expect(entity.scheduleSettings.maxSchedulesPerDay == 10)
    #expect(entity.scheduleSettings.advanceRegistrationDays == 30)
    #expect(entity.scheduleSettings.cancellationDeadlineHours == 168)
  }

  // MARK: - 동시성 테스트

  @Test("동시 관리자 작업 처리")
  func test_concurrent_manager_operations() async throws {
    // Given
    let repository = createMockManagerRepository()

    // When
    await withTaskGroup(of: Void.self) { group in
      // 동시에 여러 관리자 작업 수행
      group.addTask {
        do {
          _ = try await repository.fetchOverallAttendanceStatistics()
        } catch {
          // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
        }
      }

      group.addTask {
        do {
          _ = try await repository.fetchAllMembers()
        } catch {
          // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
        }
      }

      group.addTask {
        do {
          _ = try await repository.fetchSystemSettings()
        } catch {
          // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
        }
      }

      group.addTask {
        do {
          _ = try await repository.fetchDashboardData()
        } catch {
          // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
        }
      }
    }

    // Then: 동시성 작업이 크래시나 데드락 없이 완료되어야 함
    #expect(true)
  }

  @Test("동시 팀원 권한 변경 처리")
  func test_concurrent_member_role_updates() async throws {
    // Given
    let repository = createMockManagerRepository()
    let userIds = [2001, 2002, 2003, 2004, 2005]

    // When
    await withTaskGroup(of: Void.self) { group in
      for (index, userId) in userIds.enumerated() {
        group.addTask {
          do {
            let role: MemberRole = index % 2 == 0 ? .manager : .member
            try await repository.updateMemberRole(userId: userId, newRole: role)
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

// MARK: - Mock MoyaProvider for Manager

extension MockMoyaProvider where Target == ManagerService {

  override func request<T: Decodable>(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) async throws -> T {
    if let managerTarget = target as? ManagerService {
      return try createMockManagerResponse(for: managerTarget) as! T
    }

    throw ManagerError.networkError
  }

  private func createMockManagerResponse<T: Decodable>(for target: ManagerService) throws -> T {
    switch target {
    case .fetchOverallAttendanceStatistics:
      let topTeams = [
        TopPerformingTeamDTO(teamId: 1, teamName: "iOS팀", attendanceRate: 92.0, memberCount: 8),
        TopPerformingTeamDTO(teamId: 2, teamName: "백엔드팀", attendanceRate: 88.5, memberCount: 6),
        TopPerformingTeamDTO(teamId: 3, teamName: "웹팀", attendanceRate: 85.2, memberCount: 10)
      ]

      let monthlyTrends = [
        MonthlyTrendDTO(month: "2024-11", attendanceRate: 78.5, totalSchedules: 15),
        MonthlyTrendDTO(month: "2024-12", attendanceRate: 82.0, totalSchedules: 18),
        MonthlyTrendDTO(month: "2025-01", attendanceRate: 85.5, totalSchedules: 20),
        MonthlyTrendDTO(month: "2025-02", attendanceRate: 83.2, totalSchedules: 16),
        MonthlyTrendDTO(month: "2025-03", attendanceRate: 87.8, totalSchedules: 22),
        MonthlyTrendDTO(month: "2025-04", attendanceRate: 89.1, totalSchedules: 19)
      ]

      let statistics = OverallAttendanceStatisticsDTO(
        totalMembers: 30,
        totalSchedules: 50,
        overallAttendanceRate: 85.5,
        averageLateMinutes: 12.3,
        topPerformingTeams: topTeams,
        monthlyTrends: monthlyTrends,
        lastUpdated: Date()
      )
      return statistics as! T

    case .fetchAllMembers(let teamId):
      if let teamId = teamId, teamId == -999 {
        throw ManagerError.networkError
      }
      if let teamId = teamId, teamId == 99999 {
        return [] as! T // 빈 배열 반환
      }

      let members = [
        MemberInfoDTO(
          userId: 1001, name: "홍길동", email: "hong@ddd.com", role: "manager",
          teamName: "iOS팀", partName: "iOS 개발자", generation: "10기",
          attendanceRate: 95.0, lateCount: 1, absentCount: 0, isActive: true,
          joinDate: Date().addingTimeInterval(-7776000), lastAttendance: Date()
        ),
        MemberInfoDTO(
          userId: 1002, name: "김철수", email: "kim@ddd.com", role: "member",
          teamName: "Android팀", partName: "Android 개발자", generation: "10기",
          attendanceRate: 88.0, lateCount: 3, absentCount: 1, isActive: true,
          joinDate: Date().addingTimeInterval(-6048000), lastAttendance: Date().addingTimeInterval(-86400)
        ),
        MemberInfoDTO(
          userId: 1003, name: "이영희", email: "lee@ddd.com", role: "member",
          teamName: "웹팀", partName: "프론트엔드 개발자", generation: "10기",
          attendanceRate: 92.5, lateCount: 2, absentCount: 0, isActive: true,
          joinDate: Date().addingTimeInterval(-5184000), lastAttendance: Date()
        ),
        MemberInfoDTO(
          userId: 1004, name: "박민수", email: "park@ddd.com", role: "member",
          teamName: "백엔드팀", partName: "백엔드 개발자", generation: "10기",
          attendanceRate: 86.0, lateCount: 4, absentCount: 2, isActive: true,
          joinDate: Date().addingTimeInterval(-4320000), lastAttendance: Date().addingTimeInterval(-172800)
        ),
        MemberInfoDTO(
          userId: 1005, name: "최지원", email: "choi@ddd.com", role: "member",
          teamName: "디자인팀", partName: "UI/UX 디자이너", generation: "9기",
          attendanceRate: 90.0, lateCount: 2, absentCount: 1, isActive: false,
          joinDate: Date().addingTimeInterval(-15552000), lastAttendance: Date().addingTimeInterval(-604800)
        )
      ]
      return members as! T

    case .updateMemberRole(let userId, _):
      if userId == -1 {
        throw ManagerError.unauthorized
      }
      return () as! T

    case .addNewMember(let request):
      if request.email == "duplicate@ddd.com" {
        throw ManagerError.duplicateEmail
      }

      let newMember = AddMemberResponseDTO(
        userId: 2001,
        name: request.name,
        email: request.email,
        teamName: "iOS팀",
        partName: "iOS 개발자",
        role: request.role == "manager" ? .manager : .member,
        generation: request.generation,
        isSuccessful: true,
        message: "새 멤버가 성공적으로 추가되었습니다",
        inviteEmailSent: true
      )
      return newMember as! T

    case .removeMember(let userId, _):
      if userId == -9999 {
        throw ManagerError.memberNotFound
      }
      return () as! T

    case .fetchSystemSettings:
      let attendanceSettings = AttendanceSettingsDTO(
        lateThresholdMinutes: 10,
        absentThresholdMinutes: 30,
        autoMarkAbsentEnabled: true
      )

      let notificationSettings = NotificationSettingsDTO(
        reminderBeforeMinutes: 30,
        dailyReportEnabled: true,
        weeklyReportEnabled: true
      )

      let scheduleSettings = ScheduleSettingsDTO(
        maxSchedulesPerDay: 3,
        advanceRegistrationDays: 7,
        cancellationDeadlineHours: 24
      )

      let settings = SystemSettingsDTO(
        attendanceSettings: attendanceSettings,
        notificationSettings: notificationSettings,
        scheduleSettings: scheduleSettings,
        lastModified: Date(),
        modifiedBy: "시스템관리자"
      )
      return settings as! T

    case .updateSystemSettings(let request):
      if request.attendanceSettings.lateThresholdMinutes < 0 {
        throw ManagerError.invalidSettingsValue
      }
      return () as! T

    case .createBulkSchedules(let schedules):
      let createdSchedules = schedules.enumerated().map { index, schedule in
        CreatedScheduleDTO(
          scheduleId: 3001 + index,
          title: schedule.title,
          teamIds: schedule.targetTeamIds
        )
      }

      let response = BulkScheduleCreationResponseDTO(
        createdSchedules: createdSchedules,
        failedSchedules: [],
        successCount: schedules.count,
        failureCount: 0,
        totalAffectedMembers: 45,
        executionTime: 2.3
      )
      return response as! T

    case .fetchDashboardData:
      let recentActivities = [
        DashboardActivityDTO(type: "attendance", description: "홍길동님이 출석했습니다", userId: 1001, userName: "홍길동", timestamp: Date()),
        DashboardActivityDTO(type: "schedule", description: "새로운 일정이 생성되었습니다", userId: 1001, userName: "관리자", timestamp: Date().addingTimeInterval(-300)),
        DashboardActivityDTO(type: "member", description: "새 멤버가 가입했습니다", userId: 2001, userName: "박영희", timestamp: Date().addingTimeInterval(-600)),
        DashboardActivityDTO(type: "attendance", description: "김철수님이 지각 출석했습니다", userId: 1002, userName: "김철수", timestamp: Date().addingTimeInterval(-900)),
        DashboardActivityDTO(type: "system", description: "시스템 설정이 업데이트되었습니다", userId: 1001, userName: "관리자", timestamp: Date().addingTimeInterval(-1200)),
        DashboardActivityDTO(type: "attendance", description: "이영희님이 출석했습니다", userId: 1003, userName: "이영희", timestamp: Date().addingTimeInterval(-1500)),
        DashboardActivityDTO(type: "schedule", description: "일정이 취소되었습니다", userId: 1001, userName: "관리자", timestamp: Date().addingTimeInterval(-1800)),
        DashboardActivityDTO(type: "member", description: "멤버 권한이 변경되었습니다", userId: 1002, userName: "김철수", timestamp: Date().addingTimeInterval(-2100)),
        DashboardActivityDTO(type: "attendance", description: "박민수님이 결석했습니다", userId: 1004, userName: "박민수", timestamp: Date().addingTimeInterval(-2400)),
        DashboardActivityDTO(type: "system", description: "데이터베이스 백업이 완료되었습니다", userId: 0, userName: "시스템", timestamp: Date().addingTimeInterval(-2700))
      ]

      let upcomingDeadlines = [
        DashboardDeadlineDTO(type: "schedule_registration", description: "정기모임 등록 마감", deadline: Date().addingTimeInterval(3600), priority: "high"),
        DashboardDeadlineDTO(type: "report_submission", description: "월간 보고서 제출", deadline: Date().addingTimeInterval(86400), priority: "medium"),
        DashboardDeadlineDTO(type: "member_evaluation", description: "멤버 평가 기간", deadline: Date().addingTimeInterval(172800), priority: "low"),
        DashboardDeadlineDTO(type: "system_maintenance", description: "시스템 정기 점검", deadline: Date().addingTimeInterval(259200), priority: "medium"),
        DashboardDeadlineDTO(type: "team_meeting", description: "팀 리더 회의", deadline: Date().addingTimeInterval(345600), priority: "high")
      ]

      let teamPerformance = [
        TeamPerformanceDTO(teamId: 1, teamName: "iOS팀", attendanceRate: 92.0, averageScore: 4.5, memberCount: 8),
        TeamPerformanceDTO(teamId: 2, teamName: "Android팀", attendanceRate: 88.5, averageScore: 4.2, memberCount: 6),
        TeamPerformanceDTO(teamId: 3, teamName: "웹팀", attendanceRate: 85.2, averageScore: 4.0, memberCount: 10),
        TeamPerformanceDTO(teamId: 4, teamName: "백엔드팀", attendanceRate: 89.8, averageScore: 4.3, memberCount: 7)
      ]

      let dashboardData = DashboardDataDTO(
        todayAttendanceCount: 25,
        todayScheduleCount: 3,
        pendingApprovals: 8,
        recentActivities: recentActivities,
        upcomingDeadlines: upcomingDeadlines,
        teamPerformance: teamPerformance,
        lastRefreshed: Date()
      )
      return dashboardData as! T

    default:
      throw ManagerError.networkError
    }
  }
}

// MARK: - Mock DTOs 및 Entities는 길이 관계로 별도 파일로 분리 가능

// MARK: - Mock DTOs

struct OverallAttendanceStatisticsDTO: Codable {
  let totalMembers: Int
  let totalSchedules: Int
  let overallAttendanceRate: Double
  let averageLateMinutes: Double
  let topPerformingTeams: [TopPerformingTeamDTO]
  let monthlyTrends: [MonthlyTrendDTO]
  let lastUpdated: Date

  func toDomain() -> OverallAttendanceStatisticsEntity {
    return OverallAttendanceStatisticsEntity(
      totalMembers: totalMembers,
      totalSchedules: totalSchedules,
      overallAttendanceRate: overallAttendanceRate,
      averageLateMinutes: averageLateMinutes,
      topPerformingTeams: topPerformingTeams.map { $0.toDomain() },
      monthlyTrends: monthlyTrends.map { $0.toDomain() },
      lastUpdated: lastUpdated
    )
  }
}

struct TopPerformingTeamDTO: Codable {
  let teamId: Int
  let teamName: String
  let attendanceRate: Double
  let memberCount: Int

  func toDomain() -> TopPerformingTeamEntity {
    return TopPerformingTeamEntity(
      teamId: teamId,
      teamName: teamName,
      attendanceRate: attendanceRate,
      memberCount: memberCount
    )
  }
}

struct MonthlyTrendDTO: Codable {
  let month: String
  let attendanceRate: Double
  let totalSchedules: Int

  func toDomain() -> MonthlyTrendEntity {
    return MonthlyTrendEntity(
      month: month,
      attendanceRate: attendanceRate,
      totalSchedules: totalSchedules
    )
  }
}

struct MemberInfoDTO: Codable {
  let userId: Int
  let name: String
  let email: String
  let role: String
  let teamName: String
  let partName: String
  let generation: String
  let attendanceRate: Double
  let lateCount: Int
  let absentCount: Int
  let isActive: Bool
  let joinDate: Date
  let lastAttendance: Date?

  func toDomain() -> MemberInfoEntity {
    return MemberInfoEntity(
      userId: userId,
      name: name,
      email: email,
      role: role == "manager" ? .manager : .member,
      teamName: teamName,
      partName: partName,
      generation: generation,
      attendanceRate: attendanceRate,
      lateCount: lateCount,
      absentCount: absentCount,
      isActive: isActive,
      joinDate: joinDate,
      lastAttendance: lastAttendance
    )
  }
}

struct AddMemberResponseDTO: Codable {
  let userId: Int
  let name: String
  let email: String
  let teamName: String
  let partName: String
  let role: MemberRole
  let generation: String
  let isSuccessful: Bool
  let message: String
  let inviteEmailSent: Bool

  func toDomain() -> AddMemberResponseEntity {
    return AddMemberResponseEntity(
      userId: userId,
      name: name,
      email: email,
      teamName: teamName,
      partName: partName,
      role: role,
      generation: generation,
      isSuccessful: isSuccessful,
      message: message,
      inviteEmailSent: inviteEmailSent
    )
  }
}

struct SystemSettingsDTO: Codable {
  let attendanceSettings: AttendanceSettingsDTO
  let notificationSettings: NotificationSettingsDTO
  let scheduleSettings: ScheduleSettingsDTO
  let lastModified: Date
  let modifiedBy: String

  func toDomain() -> SystemSettingsEntity {
    return SystemSettingsEntity(
      attendanceSettings: attendanceSettings.toDomain(),
      notificationSettings: notificationSettings.toDomain(),
      scheduleSettings: scheduleSettings.toDomain(),
      lastModified: lastModified,
      modifiedBy: modifiedBy
    )
  }
}

struct AttendanceSettingsDTO: Codable {
  let lateThresholdMinutes: Int
  let absentThresholdMinutes: Int
  let autoMarkAbsentEnabled: Bool

  func toDomain() -> AttendanceSettingsEntity {
    return AttendanceSettingsEntity(
      lateThresholdMinutes: lateThresholdMinutes,
      absentThresholdMinutes: absentThresholdMinutes,
      autoMarkAbsentEnabled: autoMarkAbsentEnabled
    )
  }
}

struct NotificationSettingsDTO: Codable {
  let reminderBeforeMinutes: Int
  let dailyReportEnabled: Bool
  let weeklyReportEnabled: Bool

  func toDomain() -> NotificationSettingsEntity {
    return NotificationSettingsEntity(
      reminderBeforeMinutes: reminderBeforeMinutes,
      dailyReportEnabled: dailyReportEnabled,
      weeklyReportEnabled: weeklyReportEnabled
    )
  }
}

struct ScheduleSettingsDTO: Codable {
  let maxSchedulesPerDay: Int
  let advanceRegistrationDays: Int
  let cancellationDeadlineHours: Int

  func toDomain() -> ScheduleSettingsEntity {
    return ScheduleSettingsEntity(
      maxSchedulesPerDay: maxSchedulesPerDay,
      advanceRegistrationDays: advanceRegistrationDays,
      cancellationDeadlineHours: cancellationDeadlineHours
    )
  }
}

struct BulkScheduleCreationResponseDTO: Codable {
  let createdSchedules: [CreatedScheduleDTO]
  let failedSchedules: [FailedScheduleDTO]
  let successCount: Int
  let failureCount: Int
  let totalAffectedMembers: Int
  let executionTime: Double

  func toDomain() -> BulkScheduleCreationEntity {
    return BulkScheduleCreationEntity(
      createdSchedules: createdSchedules.map { $0.toDomain() },
      failedSchedules: failedSchedules.map { $0.toDomain() },
      successCount: successCount,
      failureCount: failureCount,
      totalAffectedMembers: totalAffectedMembers,
      executionTime: executionTime
    )
  }
}

struct CreatedScheduleDTO: Codable {
  let scheduleId: Int
  let title: String
  let teamIds: [Int]

  func toDomain() -> CreatedScheduleEntity {
    return CreatedScheduleEntity(
      scheduleId: scheduleId,
      title: title,
      teamIds: teamIds
    )
  }
}

struct FailedScheduleDTO: Codable {
  let title: String
  let reason: String
  let errorCode: String

  func toDomain() -> FailedScheduleEntity {
    return FailedScheduleEntity(
      title: title,
      reason: reason,
      errorCode: errorCode
    )
  }
}

struct DashboardDataDTO: Codable {
  let todayAttendanceCount: Int
  let todayScheduleCount: Int
  let pendingApprovals: Int
  let recentActivities: [DashboardActivityDTO]
  let upcomingDeadlines: [DashboardDeadlineDTO]
  let teamPerformance: [TeamPerformanceDTO]
  let lastRefreshed: Date

  func toDomain() -> DashboardDataEntity {
    return DashboardDataEntity(
      todayAttendanceCount: todayAttendanceCount,
      todayScheduleCount: todayScheduleCount,
      pendingApprovals: pendingApprovals,
      recentActivities: recentActivities.map { $0.toDomain() },
      upcomingDeadlines: upcomingDeadlines.map { $0.toDomain() },
      teamPerformance: teamPerformance.map { $0.toDomain() },
      lastRefreshed: lastRefreshed
    )
  }
}

struct DashboardActivityDTO: Codable {
  let type: String
  let description: String
  let userId: Int
  let userName: String
  let timestamp: Date

  func toDomain() -> DashboardActivityEntity {
    return DashboardActivityEntity(
      type: type,
      description: description,
      userId: userId,
      userName: userName,
      timestamp: timestamp
    )
  }
}

struct DashboardDeadlineDTO: Codable {
  let type: String
  let description: String
  let deadline: Date
  let priority: String

  func toDomain() -> DashboardDeadlineEntity {
    return DashboardDeadlineEntity(
      type: type,
      description: description,
      deadline: deadline,
      priority: priority
    )
  }
}

struct TeamPerformanceDTO: Codable {
  let teamId: Int
  let teamName: String
  let attendanceRate: Double
  let averageScore: Double
  let memberCount: Int

  func toDomain() -> TeamPerformanceEntity {
    return TeamPerformanceEntity(
      teamId: teamId,
      teamName: teamName,
      attendanceRate: attendanceRate,
      averageScore: averageScore,
      memberCount: memberCount
    )
  }
}

// MARK: - Request DTOs

struct AddMemberRequest {
  let name: String
  let email: String
  let teamId: Int
  let partId: Int
  let generation: String
  let role: MemberRole
  let inviteCode: String
}

struct SystemSettingsUpdateRequest {
  let attendanceSettings: AttendanceSettingsRequest
  let notificationSettings: NotificationSettingsRequest
  let scheduleSettings: ScheduleSettingsRequest
}

struct AttendanceSettingsRequest {
  let lateThresholdMinutes: Int
  let absentThresholdMinutes: Int
  let autoMarkAbsentEnabled: Bool
}

struct NotificationSettingsRequest {
  let reminderBeforeMinutes: Int
  let dailyReportEnabled: Bool
  let weeklyReportEnabled: Bool
}

struct ScheduleSettingsRequest {
  let maxSchedulesPerDay: Int
  let advanceRegistrationDays: Int
  let cancellationDeadlineHours: Int
}

struct BulkScheduleRequest {
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let location: String
  let scheduleType: String
  let targetTeamIds: [Int]
}

// MARK: - Mock Entities

enum MemberRole: String, Codable {
  case manager = "manager"
  case member = "member"
}

struct OverallAttendanceStatisticsEntity {
  let totalMembers: Int
  let totalSchedules: Int
  let overallAttendanceRate: Double
  let averageLateMinutes: Double
  let topPerformingTeams: [TopPerformingTeamEntity]
  let monthlyTrends: [MonthlyTrendEntity]
  let lastUpdated: Date
}

struct TopPerformingTeamEntity {
  let teamId: Int
  let teamName: String
  let attendanceRate: Double
  let memberCount: Int
}

struct MonthlyTrendEntity {
  let month: String
  let attendanceRate: Double
  let totalSchedules: Int
}

struct MemberInfoEntity {
  let userId: Int
  let name: String
  let email: String
  let role: MemberRole
  let teamName: String
  let partName: String
  let generation: String
  let attendanceRate: Double
  let lateCount: Int
  let absentCount: Int
  let isActive: Bool
  let joinDate: Date
  let lastAttendance: Date?
}

struct AddMemberResponseEntity {
  let userId: Int
  let name: String
  let email: String
  let teamName: String
  let partName: String
  let role: MemberRole
  let generation: String
  let isSuccessful: Bool
  let message: String
  let inviteEmailSent: Bool
}

struct SystemSettingsEntity {
  let attendanceSettings: AttendanceSettingsEntity
  let notificationSettings: NotificationSettingsEntity
  let scheduleSettings: ScheduleSettingsEntity
  let lastModified: Date
  let modifiedBy: String
}

struct AttendanceSettingsEntity {
  let lateThresholdMinutes: Int
  let absentThresholdMinutes: Int
  let autoMarkAbsentEnabled: Bool
}

struct NotificationSettingsEntity {
  let reminderBeforeMinutes: Int
  let dailyReportEnabled: Bool
  let weeklyReportEnabled: Bool
}

struct ScheduleSettingsEntity {
  let maxSchedulesPerDay: Int
  let advanceRegistrationDays: Int
  let cancellationDeadlineHours: Int
}

struct BulkScheduleCreationEntity {
  let createdSchedules: [CreatedScheduleEntity]
  let failedSchedules: [FailedScheduleEntity]
  let successCount: Int
  let failureCount: Int
  let totalAffectedMembers: Int
  let executionTime: Double
}

struct CreatedScheduleEntity {
  let scheduleId: Int
  let title: String
  let teamIds: [Int]
}

struct FailedScheduleEntity {
  let title: String
  let reason: String
  let errorCode: String
}

struct DashboardDataEntity {
  let todayAttendanceCount: Int
  let todayScheduleCount: Int
  let pendingApprovals: Int
  let recentActivities: [DashboardActivityEntity]
  let upcomingDeadlines: [DashboardDeadlineEntity]
  let teamPerformance: [TeamPerformanceEntity]
  let lastRefreshed: Date
}

struct DashboardActivityEntity {
  let type: String
  let description: String
  let userId: Int
  let userName: String
  let timestamp: Date
}

struct DashboardDeadlineEntity {
  let type: String
  let description: String
  let deadline: Date
  let priority: String
}

struct TeamPerformanceEntity {
  let teamId: Int
  let teamName: String
  let attendanceRate: Double
  let averageScore: Double
  let memberCount: Int
}

// MARK: - Mock Errors

enum ManagerError: Error {
  case unauthorized
  case duplicateEmail
  case memberNotFound
  case invalidSettingsValue
  case networkError
}