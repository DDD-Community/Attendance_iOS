//
//  MemberCoordinatorView.swift
//  Presentation
//
//  Created by DDD on 1/2/25.
//

import SwiftUI

import ComposableArchitecture
import TCAFlow
import Profile

public struct MemberCoordinatorView: View {
  @Bindable private var store: StoreOf<MemberCoordinator>
  
  public init(
    store: StoreOf<MemberCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCAFlowRouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
      case .member(let store):
        MemberMainView(store: store)
          .navigationBarBackButtonHidden()

      case .profile(let profileStore):
       ProfileCoordinatorView(store: profileStore)
        .navigationBarBackButtonHidden()

      case .qrCode(let qrCodeStore):
        MemberQRCodeView(store: qrCodeStore) {
          store.send(.inner(.onResume))
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
      }
    }
  }
}
