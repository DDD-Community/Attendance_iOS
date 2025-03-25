//
//  CoreMemberCoordinatorView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/4/24.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

public struct CoreMemberCoordinatorView: View {
  @Bindable private var store: StoreOf<CoreMemberCoordinator>
  
  public init(
    store: StoreOf<CoreMemberCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
      case .coreMember(let coreMember):
        CoreMemberMainView(store: coreMember)
          .navigationBarBackButtonHidden()
        
      case .mangeProfile(let managerProfileStore):
        ManagerProfileView(store: managerProfileStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
        
      case .scheduleEvent(let scheduleEventStore):
        ScheduleEventView(store: scheduleEventStore) {
          store.send(.view(.backAction))
        }
        .navigationBarBackButtonHidden()
      }
    }
  }
}
