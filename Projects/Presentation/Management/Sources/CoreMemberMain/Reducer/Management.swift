//
//  Management.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import Foundation
import SwiftUI

import Core
import Shareds

import ComposableArchitecture
import KeychainAccess
import FirebaseAuth

@Reducer
public struct Management {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var isExpandedDropDown: Bool = false
    var selectedIDropDownItem = "출석"
    var dropDownItem: [String] = SelectDropDownItem.item
    var selectDropDownItem: SelectDropDownItem = .attandance
    
    var attendanceCheck = AttendanceCheck.State()
    var schedule = ScheduleManager.State()
    
    var qrcodeImage: ImageAsset = .qrCode
    var eventImage: ImageAsset = .eventGenerate
    var managerProfilemage: ImageAsset = .managementProfile
    
    
    @Presents var destination: Destination.State?
  
    
    public init( ) { }
  }
  
  public enum Action : BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    case attendanceCheck(AttendanceCheck.Action)
    case schedule(ScheduleManager.Action)
  }
  
  // MARK: - View action
  
  @CasePathable
  public enum View: Equatable {
    case presentQrcode
    case closeModal
  }
  
  // MARK: - 비동기 처리 액션
  public enum AsyncAction: Equatable {
    
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    
  }
  
  // MARK: - 네비게이션 연결 액션
  public enum NavigationAction: Equatable {
    case presentSchedule
    case presentManagerProfile
    
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case qrcode(QRCode)
  }
  
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .binding(\.isExpandedDropDown):
        return .none
        
      case .destination(_):
        return .none
        
        // MARK: - ViewAction
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
        // MARK: - AsyncAction
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
        // MARK: - InnerAction
      case .inner(let InnerAction):
        return handleInnerAction(state: &state, action: InnerAction)
        
        // MARK: - NavigationAction
      case .navigation(let NavigationAction):
        return handleNavigationAction(state: &state, action: NavigationAction)
        
      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
    Scope(state: \.attendanceCheck, action: \.attendanceCheck) {
      AttendanceCheck()
    }
    Scope(state: \.schedule, action: \.schedule) {
      ScheduleManager()
    }
  }
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .presentQrcode:
      state.destination = .qrcode(.init())
      return .none
      
    case .closeModal:
      state.destination = nil
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentSchedule:
      return .run {  send in
        
      }
      
    case .presentManagerProfile:
      return .none
    }
  }
}

