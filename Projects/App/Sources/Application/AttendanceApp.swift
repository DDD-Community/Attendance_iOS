//
//  AttendanceApp.swift
//  DDDAttendance
//
//  Created by DDD on 10/29/24.
//

import SwiftUI

import FeatureAssembly

import ComposableArchitecture

@main
struct AttendanceApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      let store = Store(initialState: AppReducer.State()) {
        AppReducer()
          ._printChanges()
          ._printChanges(.actionLabels)
      } withDependencies: {
        $0.continuousClock = ContinuousClock()
      }

      AppView(store: store)
    }
  }
}
