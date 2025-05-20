//
//  MemberCoordinatorView.swift
//  Presentation
//
//  Created by 홍은표 on 1/2/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

public struct MemberCoordinatorView: View {
  @Bindable private var store: StoreOf<MemberCoordinator>
  
  public init(
    store: StoreOf<MemberCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
      case .member(let store):
        MemberMainView(store: store)
          .navigationBarBackButtonHidden()
        
      case .profile(let profileStore):
        ManagerProfileView(store: profileStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
      }
    }
  }
}
