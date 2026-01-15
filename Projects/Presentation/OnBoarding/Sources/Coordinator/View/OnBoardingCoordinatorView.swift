//
//  OnBoardingCoordinatorView.swift
//  OnBoarding
//
//  Created by Wonji Suh  on 1/6/26.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

public struct OnBoardingCoordinatorView: View {
  @Bindable var store: StoreOf<OnBoardingCoordinator>

  public init(
    store: StoreOf<OnBoardingCoordinator>
  ) {
    self.store = store
  }

  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
        case .InviteCode(let InviteCodeStore):
          InviteCodeView(store: InviteCodeStore) {
            store.send(.navigation(.backToRoot))
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
