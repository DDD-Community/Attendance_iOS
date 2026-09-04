//
//  StaffFeature.swift
//  Management
//
//  Created by DDD on 6/6/24.
//

import Foundation
import SwiftUI

import DDDSharedUI

import ComposableArchitecture
import ManagementInterface

@Reducer
public struct StaffFeature {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var isExpandedDropDown: Bool = false
    var selectedIDropDownItem = "출석"
    var dropDownItem: [String] = SelectDropDownItem.item
    var selectDropDownItem: SelectDropDownItem = .attandance
    
    var attendanceCheck = AttendanceCheck.State()
    var schedule = ScheduleReducer.State()
    var vote = VoteFeature.State()
    
    var qrcodeImage: ImageAsset = .qrCode
    var eventImage: ImageAsset = .eventGenerate
    var managerProfilemage: ImageAsset = .managementProfile
    
    
    @Presents var destination: Destination.State?
  
    
    public init( ) { }
  }
  
  public enum Action : BindableAction {
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)
    case attendanceCheck(AttendanceCheck.Action)
    case schedule(ScheduleReducer.Action)
    case vote(VoteFeature.Action)
  }
  
  // MARK: - View action
  
  @CasePathable
  public enum View: Equatable {
    case presentQrcode
    case closeModal
    case toggleDropDown
    case closeDropDown
    case selectDropDownItem(SelectDropDownItem)
  }
  
  // MARK: - 비동기 처리 액션
  public enum AsyncAction: Equatable {
    
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    
  }
  
  // MARK: - 네비게이션 연결 액션
  /// 이동 계약은 ManagementInterface에 두어 앱이 구체 구현 없이 이벤트를 받을 수 있게 한다.
  public typealias DelegateAction = StaffDelegate
  
  @Reducer(state: .equatable)
  public enum Destination {
    case qrcode(QRCode)
  }
  
  
  public var body: some Reducer<State, Action> {
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
        
        // MARK: - DelegateAction
      case .delegate(let DelegateAction):
        return handleDelegateAction(state: &state, action: DelegateAction)
        
      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
    Scope(state: \.attendanceCheck, action: \.attendanceCheck) {
      AttendanceCheck()
    }
    Scope(state: \.schedule, action: \.schedule) {
      ScheduleReducer()
    }
    Scope(state: \.vote, action: \.vote) {
      VoteFeature()
    }
  }
}

extension StaffFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .presentQrcode:
      state.isExpandedDropDown = false
      state.destination = .qrcode(.init())
      return .none

    case .closeModal:
      state.destination = nil
      return .none

    case .toggleDropDown:
      state.isExpandedDropDown.toggle()
      return .none

    case .closeDropDown:
      state.isExpandedDropDown = false
      return .none

    case let .selectDropDownItem(item):
      state.selectDropDownItem = item
      state.isExpandedDropDown = false
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

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentSchedule:
      return .run {  send in

      }

    case .presentManagerProfile:
      state.isExpandedDropDown = false
      return .none
    }
  }
}
