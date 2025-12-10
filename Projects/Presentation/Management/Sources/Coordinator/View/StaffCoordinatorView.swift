//
//  StaffCoordinatorView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/4/24.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators
import Profile

public struct StaffCoordinatorView: View {
  @Bindable private var store: StoreOf<StaffCoordinator>

  public init(
    store: StoreOf<StaffCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
      case .coreMember(let coreMember):
        StaffView(store: coreMember)
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
