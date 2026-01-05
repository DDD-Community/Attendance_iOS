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
  @Bindable private var store: StoreOf<AuthCoordinator>
  
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
        
      case .InviteCode(let InviteCodeStore):
        InviteCodeView(store: InviteCodeStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .onBoardingName(let onBoardingNameStore):
         OnBoardingNameView(store: onBoardingNameStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .selectPart(let selectPartStore):
        SelectPartView(store: selectPartStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .selectManaging(let selectManagingStore):
        SelectManagingView(store: selectManagingStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .selectTeam(let signUpSelectTeamStore):
        SelectTeamView(store: signUpSelectTeamStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
      }
    }
  }
}
