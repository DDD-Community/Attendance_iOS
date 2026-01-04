//
//  ProfileCoordinatorView.swift
//  Profile
//
//  Created by Wonji Suh  on 1/4/26.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

public struct ProfileCoordinatorView: View {
  @Bindable var store: StoreOf<ProfileCoordinator>

  public init(
    store: StoreOf<ProfileCoordinator>
  ) {
    self.store = store
  }

  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
        case .profile(let profileStore):
          ProfileView(store: profileStore) {
            store.send(.navigation(.presentRoot))
          }
          .navigationBarBackButtonHidden()

        case .web(let webStore):
          WebView(store: webStore)
            .navigationBarBackButtonHidden()

      }
    }
  }

}
