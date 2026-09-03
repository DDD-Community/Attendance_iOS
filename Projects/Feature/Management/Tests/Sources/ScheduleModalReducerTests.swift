//
//  ScheduleModalReducerTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-02
//

import ComposableArchitecture
import ScheduleDomainInterface
import Testing

@testable import Management

@MainActor
@Suite("ScheduleModal")
struct ScheduleModalReducerTests {
  @Test("스케줄 선택은 선택값을 저장하고 확인 버튼을 활성화한다")
  func selectScheduleStoresSelectionAndEnablesButton() async {
    let schedule = Self.schedule
    let store = TestStore(initialState: ScheduleModal.State()) {
      ScheduleModal()
    }

    await store.send(.view(.selectSchedule(item: schedule))) {
      $0.selectedSchedule = schedule
      $0.enableButton = true
    }
  }

  @Test("같은 스케줄을 다시 선택하면 선택을 해제한다")
  func selectingSameScheduleClearsSelection() async {
    var state = ScheduleModal.State()
    state.selectedSchedule = Self.schedule
    state.enableButton = true
    let store = TestStore(initialState: state) {
      ScheduleModal()
    }

    await store.send(.view(.selectSchedule(item: Self.schedule))) {
      $0.selectedSchedule = nil
      $0.enableButton = false
    }
  }
}

private extension ScheduleModalReducerTests {
  static let schedule = Schedule(
    id: 1,
    name: "OT",
    description: "오리엔테이션",
    month: 9,
    day: 2,
    year: 2026
  )
}
