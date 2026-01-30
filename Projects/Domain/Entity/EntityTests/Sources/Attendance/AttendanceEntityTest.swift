//
//  AttendanceEntityTest.swift
//  EntityTests
//
//  Created by TDD Automation on 2026-01-30
//

import Testing
import XCTest
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
}

class AttendanceEntityXCTest: XCTestCase {
    func test_Attendance_array_mock_data() {
        // Given
        let attendances = Attendance.mockDataArray()

        // Then
        XCTAssertEqual(attendances.count, 5)
        XCTAssertEqual(attendances[0].status, .attended)
        XCTAssertEqual(attendances[1].status, .late)
        XCTAssertEqual(attendances[2].status, .absent)
    }
}