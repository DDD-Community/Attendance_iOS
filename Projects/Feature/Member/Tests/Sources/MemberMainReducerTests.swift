//
//  MemberMainReducerTests.swift
//  MemberTests
//
//  Created by DDD on 2026-09-02
//

import ComposableArchitecture
import Testing
import MyPageDomainInterface

@testable import Member

@MainActor
@Suite("MemberMain")
struct MemberMainReducerTests {
  @Test("투표 메뉴가 비활성화되면 투표 탭 선택을 출석 탭으로 되돌린다")
  func unavailableVoteTabFallsBackToAttendance() async {
    var state = MemberMain.State()
    state.isExpandedDropDown = true
    let store = TestStore(initialState: state) {
      MemberMain()
    }

    await store.send(.view(.selectHomeTab(.vote))) {
      $0.isExpandedDropDown = false
    }
  }

  @Test("출석 요약 성공은 카운트와 결석 경고 노출 여부를 저장한다")
  func attendanceSummarySuccessStoresCounts() async {
    let summary = AttendanceSummaryResponse(
      totalAttended: 8,
      totalLate: 1,
      totalAbsent: 2
    )
    let store = TestStore(initialState: MemberMain.State()) {
      MemberMain()
    }

    await store.send(.inner(.onFetchAttendanceSummaryResponse(.success(summary)))) {
      $0.presentCount = 8
      $0.lateCount = 1
      $0.absentCount = 2
      $0.showAttendanceWarningIcon = true
    }
  }
}
