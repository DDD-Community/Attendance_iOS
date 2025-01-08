//
//  AuthCoordinatorView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/2/24.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

public struct AuthCoordinatorView: View {
  @Bindable var store: StoreOf<AuthCoordinator>
  
  public init(
    store: StoreOf<AuthCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
      case .login(let loginStore):
        LoginView(store: loginStore)
          .navigationBarBackButtonHidden()
        
      case .signUpInviteCode(let signUpInviteCodeStore):
        SignUpInviteCodeView(store: signUpInviteCodeStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .signUpName(let signUpStore):
        SignUpNameView(store: signUpStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .signUpPart(let signUpPartStore):
        SignUpPartView(store: signUpPartStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .signUpManging(let signUpMangingStore):
        SignUpSelectMangingView(store: signUpMangingStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .signUpSelectTeam(let signUpSelectTeamStore):
        SignUpSelectTeamView(store: signUpSelectTeamStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
      }
    }
  }
}

