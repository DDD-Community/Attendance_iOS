//
//  ManagementAccessibilityIDTests.swift
//  ManagementTests
//

import AttendanceDomainInterface
import Testing

@testable import Management

@Suite("Management accessibility ID")
struct ManagementAccessibilityIDTests {
  @Test("운영진 출석 화면의 고정 ID 계약")
  func fixedIdentifiers() {
    #expect(ManagementAccessibilityID.Staff.root == "management.staff.root")
    #expect(ManagementAccessibilityID.Staff.skeleton == "management.staff.skeleton")
    #expect(ManagementAccessibilityID.Attendance.root == "management.attendance.root")
    #expect(ManagementAccessibilityID.Attendance.summary == "management.attendance.summary")
    #expect(ManagementAccessibilityID.Attendance.list == "management.attendance.list")
    #expect(ManagementAccessibilityID.Attendance.listSkeleton == "management.attendance.list.skeleton")
  }

  @Test("반복 항목 ID는 안정적인 도메인 키를 붙인다")
  func dynamicIdentifiers() {
    #expect(ManagementAccessibilityID.Attendance.team(7) == "management.attendance.team.7")
    #expect(
      ManagementAccessibilityID.Attendance.card(userID: "member-id")
        == "management.attendance.card.member-id"
    )
    #expect(
      ManagementAccessibilityID.Attendance.cardEditButton(userID: "member-id")
        == "management.attendance.card.member-id.editbutton"
    )
    #expect(
      ManagementAccessibilityID.Attendance.modalStatus(.late)
        == "management.attendance.modal.status.late"
    )
  }
}
