//
//  ManagementCoordinatorView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/4/24.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators
import Profile

public struct ManagementCoordinatorView: View {
  @Bindable private var store: StoreOf<ManagementCoordinator>

  public init(
    store: StoreOf<ManagementCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
      case .coreMember(let coreMember):
        ManagementView(store: coreMember)
          .navigationBarBackButtonHidden()

      case .mangeProfile(let managerProfileStore):
        ProfileView(store: managerProfileStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
      }
    }
  }
}
