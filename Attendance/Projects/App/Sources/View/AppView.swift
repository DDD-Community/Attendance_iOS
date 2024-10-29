//
//  AppView.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 10/29/24.
//


import SwiftUI

import ComposableArchitecture
import Presentation

 struct AppView: View {
   @Bindable var store: StoreOf<AppReducer>
   
  var body: some View {
    SwitchStore(store) { state in
      switch state {
      case .splash:
        if let store = store.scope(state: \.splash, action: \.view.splash) {
          SplashView(store: store)
        }
        
      case .login:
        if let store = store.scope(state: \.login, action: \.view.login) {
          LoginView(store: store)
        }
      }
    }
  }
}
