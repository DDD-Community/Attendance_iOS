//
//  MemberAccessibilityID.swift
//  Member
//

enum MemberAccessibilityID {
  static let root = "member.home.root"
  static let skeleton = "member.home.skeleton"
  static let sectionButton = "member.home.sectionbutton"
  static let qrButton = "member.home.qrbutton"
  static let profileButton = "member.home.profilebutton"
  static let attendanceSummary = "member.attendance.summary"
  static let attendanceSummarySkeleton = "member.attendance.summary.skeleton"
  static let scheduleList = "member.schedule.list"
  static let voteRoot = "member.vote.root"

  static func schedule(_ scheduleID: Int) -> String {
    "member.schedule.\(scheduleID)"
  }
}
