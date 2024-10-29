//
//  AttendanceApp.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 10/29/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct AttendanceApp: App {
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  init() {
    
  }
  
  var body: some Scene {
    WindowGroup {
      let store = Store(initialState: AppReducer.State()) {
        AppReducer()
          ._printChanges()
          ._printChanges(.actionLabels)
      }
      
      AppView(store: store)
    }
  }
}
