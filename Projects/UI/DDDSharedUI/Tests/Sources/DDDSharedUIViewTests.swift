//
//  DDDSharedUIViewTests.swift
//  DDDSharedUITests
//
//  Created by DDD on 9/4/26.
//

import SwiftUI
import Testing
import UIKit
@testable import DDDSharedUI

@MainActor
@Suite("DDDSharedUI rendering")
struct DDDSharedUIViewTests {
  @Test("공유 UI의 주요 상태를 모두 렌더링한다")
  func rendersPublicComponents() {
    render(
      AttendanceCard(
        attendanceCount: 3,
        lateCount: 1,
        absentCount: 2,
        showWarning: true
      )
    )
    render(
      AttendanceCard(
        attendanceCount: 0,
        lateCount: 0,
        absentCount: 0,
        showWarning: false
      )
    )
    render(
      AttendanceStatusText(
        name: "홍길동",
        generataion: "13",
        roleType: "운영진",
        nameColor: .primary,
        roleTypeColor: .secondary,
        generationColor: .gray,
        backGroudColor: .black
      )
    )
    render(SelectPartItem(content: "iOS", isActive: true, completion: {}))
    render(SelectPartItem(content: "Server", isActive: false, completion: {}))
    render(SelectTeamIteam(content: "Team 1", isActive: true, completion: {}))
    render(SelectTeamIteam(content: "Team 2", isActive: false, completion: {}))
    render(SignUpPartText(content: "파트", title: "파트를 선택해 주세요", subtitle: "하나만 선택할 수 있어요"))
    render(SignUpPartText(content: "파트", title: "파트를 선택해 주세요", subtitle: ""))
  }

  @Test("일정 셀의 기본, 스탬프, 점선 상태를 렌더링한다")
  func rendersScheduleCellStates() {
    let basic = ScheduleCellStyle(
      backgroundColor: .white,
      stampImage: nil,
      dashBorder: false,
      monthDayOpacity: 1,
      titleDescriptionOpacity: 1
    )
    let completed = ScheduleCellStyle(
      backgroundColor: .gray,
      stampImage: Image(systemName: "checkmark.seal"),
      dashBorder: true,
      monthDayOpacity: 0.5,
      titleDescriptionOpacity: 0.5
    )

    render(ScheduleCell(month: 9, day: 2, title: "정기 모임", description: "서울", style: basic))
    render(ScheduleCell(month: 9, day: 9, title: "세션", description: "온라인", style: completed))
  }

  private func render<V: View>(_ view: V) {
    _ = view.body
    let controller = UIHostingController(rootView: view)
    controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    #expect(controller.view.bounds.width == 390)
  }
}
