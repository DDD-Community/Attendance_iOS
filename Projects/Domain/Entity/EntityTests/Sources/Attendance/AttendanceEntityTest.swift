//
//  AttendanceEntityTest.swift
//  EntityTests
//
//  Created by TDD AI Automation on 2026-01-30
//

import Testing
@testable import Entity

@Suite("Attendance Entity Tests - AI Generated")
struct AttendanceEntityTest {

    // MARK: - 핵심 엔티티 테스트
    @Test("Attendance Mock 데이터 무결성 검증")
    func test_Attendance_mock_data_integrity() throws {
        // Given: AI가 분석한 필수 필드들
        let attendance = Attendance.mockData()

        // Then: 핵심 비즈니스 로직 검증
        #expect(attendance.userID.isEmpty == false, "사용자 ID는 필수")
        #expect(attendance.userName.isEmpty == false, "사용자 이름은 필수")
        #expect(attendance.userInfo.contains("/"), "팀/직무 정보 형식 검증")
        #expect(attendance.status != nil, "출석 상태는 필수")
    }

    @Test("출석 상태별 비즈니스 로직 검증")
    func test_attendance_status_business_logic() throws {
        // Given: 각 상태별 Mock 데이터
        let attended = Attendance.mockAttendedData()
        let late = Attendance.mockLateData()
        let absent = Attendance.mockAbsentData()

        // Then: 비즈니스 규칙 준수 검증
        #expect(attended.status == .attended)
        #expect(late.status == .late)
        #expect(absent.status == .absent)

        // 팀 정보 파싱 로직 검증
        #expect(attended.selectTeamEntity != nil, "팀 정보 파싱 성공")
        #expect(attended.selectPartEntity != nil, "직무 정보 파싱 성공")
    }

    @Test("출석 통계 계산 로직 검증")
    func test_attendance_count_calculations() throws {
        // Given: 다양한 시나리오의 통계 데이터
        let normalCount = AttendanceCount.mockData()
        let highCount = AttendanceCount.mockHighAttendanceData()
        let lowCount = AttendanceCount.mockLowAttendanceData()

        // Then: 통계 계산 규칙 검증
        let normalTotal = normalCount.attendanceCount + normalCount.lateCount + normalCount.absentCount
        let highTotal = highCount.attendanceCount + highCount.lateCount + highCount.absentCount
        let lowTotal = lowCount.attendanceCount + lowCount.lateCount + lowCount.absentCount

        #expect(normalTotal > 0, "정상 통계는 0보다 커야 함")
        #expect(highCount.attendanceCount >= normalCount.attendanceCount, "높은 출석률 검증")
        #expect(lowCount.absentCount >= normalCount.absentCount, "낮은 출석률 검증")
    }

    @Test("출석 수정 요청 검증")
    func test_edit_attendance_request_validation() throws {
        // Given: 다양한 수정 시나리오
        let validRequest = EditAttendanceInput.mockData()
        let newAttendanceRequest = EditAttendanceInput.mockNewAttendanceInput()

        // Then: 요청 유효성 검증
        #expect(validRequest.userId.isEmpty == false, "사용자 ID 필수")
        #expect(validRequest.scheduleId > 0, "스케줄 ID 양수")
        #expect(newAttendanceRequest.attendanceId == nil, "신규 출석은 ID nil")
    }

    @Test("출석 수정 응답 처리 검증")
    func test_edit_attendance_response_handling() throws {
        // Given: 다양한 응답 시나리오
        let success = EditAttendance.mockSuccessData()
        let failure = EditAttendance.mockFailureData()
        let networkError = EditAttendance.mockNetworkErrorData()

        // Then: 응답 처리 로직 검증
        #expect(success.isSuccess == true && success.code == "200")
        #expect(failure.isSuccess == false && failure.code == "400")
        #expect(networkError.isSuccess == false && networkError.code == "500")

        // 에러 메시지 존재 검증
        #expect(failure.message?.isEmpty == false, "실패 시 메시지 필수")
        #expect(failure.detail?.isEmpty == false, "실패 시 상세 정보 필수")
    }

    @Test("팀별 출석 데이터 필터링 검증")
    func test_team_based_attendance_filtering() throws {
        // Given: 다양한 팀의 출석 데이터
        let allAttendances = Attendance.mockDataArray()

        // When: 팀별 필터링
        let iosTeam = allAttendances.filter { $0.userInfo.contains("iOS") }
        let androidTeam = allAttendances.filter { $0.userInfo.contains("Android") }
        let webTeam = allAttendances.filter { $0.userInfo.contains("WEB") }

        // Then: 필터링 결과 검증
        #expect(iosTeam.count > 0, "iOS 팀 데이터 존재")
        #expect(androidTeam.count > 0, "Android 팀 데이터 존재")
        #expect(webTeam.count > 0, "Web 팀 데이터 존재")

        // 팀 정보 정확성 검증
        for attendance in iosTeam {
            #expect(attendance.selectTeamEntity == .ios1 || attendance.selectTeamEntity == .ios2)
        }
    }

    @Test("출석 상태 변경 플로우 검증")
    func test_attendance_status_change_flow() throws {
        // Given: 출석 상태 변경 시나리오
        let originalAttendance = Attendance.mockAttendedData()
        let changeToLate = EditAttendanceInput.mockLateInput()
        let changeToAbsent = EditAttendanceInput.mockAbsentInput()

        // Then: 상태 변경 규칙 검증
        #expect(changeToLate.status == .late, "지각 변경 요청")
        #expect(changeToAbsent.status == .absent, "결석 변경 요청")
        #expect(changeToLate.attendanceId != nil, "기존 출석 기록 ID 필요")
    }
}