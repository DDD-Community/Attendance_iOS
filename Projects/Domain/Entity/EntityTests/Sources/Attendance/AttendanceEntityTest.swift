//
//  AttendanceEntityTest.swift
//  EntityTests
//
//  Created by TDD Automation on 2026-01-30
//

import Testing
@testable import Entity

@Suite("Attendance Entity Tests")
struct AttendanceEntityTest {

    @Test("Attendance Mock 데이터 생성 테스트")
    func test_Attendance_mock_data_creation() throws {
        // Given
        let attendance = Attendance.mockData()

        // Then
        #expect(attendance.userID == "user_001")
        #expect(attendance.userName == "김철수")
        #expect(attendance.userInfo == "iOS 1팀/iOS")
        #expect(attendance.status == .attended)
    }

    @Test("AttendanceCount Mock 데이터 테스트")
    func test_AttendanceCount_mock_data() throws {
        // Given
        let count = AttendanceCount.mockData()

        // Then
        #expect(count.attendanceCount == 18)
        #expect(count.lateCount == 2)
        #expect(count.absentCount == 0)
    }

    @Test("EditAttendance 성공 응답 테스트")
    func test_EditAttendance_success_response() throws {
        // Given
        let response = EditAttendance.mockSuccessData()

        // Then
        #expect(response.isSuccess == true)
        #expect(response.code == "200")
        #expect(response.message != nil)
    }

    @Test("Attendance 배열 Mock 데이터 테스트")
    func test_Attendance_array_mock_data() throws {
        // Given
        let attendances = Attendance.mockDataArray()

        // Then
        #expect(attendances.count == 5)
        #expect(attendances[0].status == .attended)
        #expect(attendances[1].status == .late)
        #expect(attendances[2].status == .absent)
    }

    @Test("AttendanceStatus 랜덤 Mock 데이터 테스트")
    func test_AttendanceStatus_random_mock() throws {
        // Given & When
        let randomStatus = AttendanceStatus.mockRandomStatus()

        // Then
        #expect(AttendanceStatus.allCases.contains(randomStatus))
    }

    @Test("EditAttendanceInput Mock 데이터 테스트")
    func test_EditAttendanceInput_mock_data() throws {
        // Given
        let input = EditAttendanceInput.mockData()

        // Then
        #expect(input.userId == "user_001")
        #expect(input.scheduleId == 5)
        #expect(input.status == .attended)
        #expect(input.attendanceId == 1)
    }

    @Test("EditAttendance 실패 응답 테스트")
    func test_EditAttendance_failure_response() throws {
        // Given
        let response = EditAttendance.mockFailureData()

        // Then
        #expect(response.isSuccess == false)
        #expect(response.code == "400")
        #expect(response.message?.contains("실패") == true)
    }

    @Test("AttendanceCount 다양한 시나리오 테스트")
    func test_AttendanceCount_scenarios() throws {
        // Given
        let highAttendance = AttendanceCount.mockHighAttendanceData()
        let lowAttendance = AttendanceCount.mockLowAttendanceData()
        let emptyData = AttendanceCount.mockEmptyData()

        // Then
        #expect(highAttendance.attendanceCount > lowAttendance.attendanceCount)
        #expect(lowAttendance.absentCount > emptyData.absentCount)
        #expect(emptyData.attendanceCount == 0)
    }

    @Test("Attendance 팀별 데이터 테스트")
    func test_Attendance_team_data() throws {
        // Given
        let attendances = Attendance.mockDataArray()

        // When
        let iosTeamMembers = attendances.filter { $0.userInfo.contains("iOS") }
        let androidTeamMembers = attendances.filter { $0.userInfo.contains("Android") }

        // Then
        #expect(iosTeamMembers.count > 0)
        #expect(androidTeamMembers.count > 0)
        #expect(iosTeamMembers.first?.selectTeamEntity == .ios1 || iosTeamMembers.first?.selectTeamEntity == .ios2)
    }
}