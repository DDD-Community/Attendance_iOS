//
//  AuthCoordinatorView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/2/24.
//

import SwiftUI

import OnBoarding

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
        
        case .onboarding(let onBoardingStore):
          OnBoardingCoordinatorView(store: onBoardingStore)
            .navigationBarBackButtonHidden()
      }
    }
  }
}
