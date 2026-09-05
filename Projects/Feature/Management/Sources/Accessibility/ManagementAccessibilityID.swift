//
//  ManagementAccessibilityID.swift
//  Management
//

import AttendanceDomainInterface

enum ManagementAccessibilityID {
  enum Staff {
    static let root = "management.staff.root"
    static let skeleton = "management.staff.skeleton"
    static let sectionButton = "management.staff.sectionbutton"
    static let qrButton = "management.staff.qrbutton"
    static let profileButton = "management.staff.profilebutton"
  }

  enum Attendance {
    static let root = "management.attendance.root"
    static let dateButton = "management.attendance.datebutton"
    static let summary = "management.attendance.summary"
    static let list = "management.attendance.list"
    static let listSkeleton = "management.attendance.list.skeleton"
    static let modal = "management.attendance.modal"
    static let modalStatusButton = "management.attendance.modal.statusbutton"
    static let modalConfirmButton = "management.attendance.modal.confirmbutton"

    static func team(_ teamID: Int) -> String {
      "management.attendance.team.\(teamID)"
    }

    static func card(userID: String) -> String {
      "management.attendance.card.\(userID)"
    }

    static func cardEditButton(userID: String) -> String {
      "\(card(userID: userID)).editbutton"
    }

    static func modalStatus(_ status: AttendanceStatus) -> String {
      "management.attendance.modal.status.\(status.apiKey.lowercased())"
    }
  }
}
