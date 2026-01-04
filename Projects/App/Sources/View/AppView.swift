//
//  AppView.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 10/29/24.
//

import SwiftUI

import Presentation
import Profile

import ComposableArchitecture

struct AppView: View {
  @Bindable var store: StoreOf<AppReducer>

  var body: some View {
    ZStack(alignment: .topLeading) {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)

      SwitchStore(store) { state in
        switch state {
        case .splash:
          if let splashStore = store.scope(state: \.splash, action: \.view.splash) {
            SplashView(store: splashStore)
              .transition(.opacity.combined(with: .scale(scale: 0.98)))
          }

        case .auth:
          if let authStore = store.scope(state: \.auth, action: \.view.auth) {
            AuthCoordinatorView(store: authStore)
              .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
              ))
          }

        case .coreMember:
          if let coreMemberStore = store.scope(state: \.coreMember, action: \.view.coreMember) {
            StaffCoordinatorView(store: coreMemberStore)
              .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
              ))
          }

        case .member:
          if let memberStore = store.scope(state: \.member, action: \.view.member) {
            MemberCoordinatorView(store: memberStore)
              .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
              ))
          }
        }
      }
    }
    .animation(
      .spring(response: 0.52, dampingFraction: 0.94, blendDuration: 0.14),
      value: store.state.screenType
    )
  }
}


#Preview {
  AuthCoordinatorView(
    store: .init(
      initialState: AuthCoordinator.State(),
      reducer: {
        AuthCoordinator()
      })
  )
}


#Preview {
  StaffCoordinatorView(
    store: .init(
      initialState: StaffCoordinator.State(),
      reducer: {
        StaffCoordinator()
      })
  )
}
