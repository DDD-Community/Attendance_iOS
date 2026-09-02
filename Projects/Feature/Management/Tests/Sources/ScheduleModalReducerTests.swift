//
//  ScheduleModalReducerTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-02
//

import ComposableArchitecture
import Entity
import EntityTesting
import Testing

@testable import Management

@MainActor
@Suite("ScheduleModal")
struct ScheduleModalReducerTests {
  @Test("스케줄 선택은 선택값을 저장하고 확인 버튼을 활성화한다")
  func selectScheduleStoresSelectionAndEnablesButton() async {
    let schedule = EntityFixture.schedule
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
    state.selectedSchedule = EntityFixture.schedule
    state.enableButton = true
    let store = TestStore(initialState: state) {
      ScheduleModal()
    }

    await store.send(.view(.selectSchedule(item: EntityFixture.schedule))) {
      $0.selectedSchedule = nil
      $0.enableButton = false
    }
  }
}

private extension ScheduleModalReducerTests {
}
