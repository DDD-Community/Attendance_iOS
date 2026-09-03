//
//  AttendanceApp.swift
//  DDDAttendance
//
//  Created by DDD on 10/29/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureAssembly

@main
struct AttendanceApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      let store = withDependencies {
        $0.registerAppDependencies()
        // 앱 타깃을 호스트로 사용하는 단위 테스트에서도 화면 전환 지연은 실제 clock으로 동작해야 한다.
        $0.continuousClock = ContinuousClock()
      } operation: {
        Store(initialState: AppReducer.State()) {
          AppReducer()
            ._printChanges()
            ._printChanges(.actionLabels)
        }
      }

      AppView(store: store)
    }
  }
}
