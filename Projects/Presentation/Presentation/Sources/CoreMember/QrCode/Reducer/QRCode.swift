//
//  QRCode.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation
import ComposableArchitecture

import Utill
import Networkings

@Reducer
public struct QRCode {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var scannedText = ""
    var isScanning = true
    let scannerSize: CGFloat = 240
    var isPresent: Bool = false
    
    var attendanceCheckModel: QRValidateModel?
    var sceduleFilterModel: ScheduleModel?
    var filterSceduleAttendanceModel: AttendanceListModel?
    var modifyAttendanceModel: ModifyAttendanceModel?
    var scheduleId: String = ""
    var nowDate = Date()
    
    public init() {}
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    
  }
  
  //MARK: - ViewAction
  @CasePathable
  public enum View {
    case stopScanning
  }
  
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case qrCodeValidate
    case filterSchedule
    case filterScheduleAttendance(userId: Int)
    case modifyAttendance(attendanceId: String)
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case qrCodeValidateReponse(Result<QRValidateModel, CustomError>)
    case filterScheduleReponse(Result<ScheduleModel, CustomError>)
    case filterScheduleAttendanceReponse(Result<AttendanceListModel, CustomError>)
    case modifyAttendanceResponse(Result<ModifyAttendanceModel, CustomError>)
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    
    
  }
  
  private struct QRCodeCancel: Hashable {}
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue
  
  @Dependency(QRCodeUseCase.self) var qrCodeUseCase
  @Dependency(ScheduleUseCase.self) var scheduleUseCase
  @Dependency(AttendanceUseCase.self) var attendanceUseCase
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
      case .navigation(let navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)
      }
    }
  }
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .stopScanning:
      state.isScanning = false
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .qrCodeValidate:
      return .run { [
        scannedText = state.scannedText
      ] send in
        let qrCodeValidateResult = await Result {
          try await qrCodeUseCase.qrAttendanceCheck(from: scannedText)
        }
        
        switch qrCodeValidateResult {
        case .success(let qrCodeValidateData):
          if let qrCodeValidateData = qrCodeValidateData {
            try await clock.sleep(for: .seconds(2))
            await send(.inner(.qrCodeValidateReponse(.success(qrCodeValidateData))))
            
            if qrCodeValidateData.code == 200 && qrCodeValidateData.data.valid == true {
              await send(.view(.stopScanning))
              await send(.async(.filterScheduleAttendance(userId: qrCodeValidateData.data.userID)))
            }
          }
          
        case .failure(let error):
          await send(.inner(.qrCodeValidateReponse(.failure(.encodingError(error.localizedDescription)))))
        }
      }
      .debounce(id: QRCodeCancel(), for: 0.3, scheduler: mainQueue)
      
    case .filterSchedule:
      return .run { [nowDate = state.nowDate] send in
        let filterScheduleResult = await Result {
          try await scheduleUseCase.filtergetSchedules(startDate: nowDate.formattedDates())
        }
        
        switch filterScheduleResult {
        case .success(let filterScheduleData):
          if let filterScheduleData = filterScheduleData {
            await send(.inner(.filterScheduleReponse(.success(filterScheduleData))))
          }
          
        case .failure(let error):
          await send(.inner(.filterScheduleReponse(.failure(.encodingError(error.localizedDescription)))))
        }
      }
      .debounce(id: QRCodeCancel(), for: 0.3, scheduler: mainQueue)
      
    case .filterScheduleAttendance(let userId):
      return .run { [
        sceduleId = state.scheduleId
      ] send in
        let filterSceduleAttendanceResult = await Result {
          try await attendanceUseCase.filterScheduleAttendance(userId: userId, scheduleId: sceduleId, startDate: Date().formattedDates())
        }
        
        switch filterSceduleAttendanceResult {
        case .success(let  filterSceduleAttendanceData):
          if let  filterSceduleAttendanceData =  filterSceduleAttendanceData {
            await send(.inner(.filterScheduleAttendanceReponse(.success(filterSceduleAttendanceData))))
            let attendanceId = filterSceduleAttendanceData.data.first?.id ?? ""
            if filterSceduleAttendanceData.code == 200 {
              await send(.async(.modifyAttendance(attendanceId: attendanceId)))
            }
          }
        case .failure(let error):
          await send(.inner(.filterScheduleAttendanceReponse(.failure(.encodingError(error.localizedDescription)))))
        }
      }
      .debounce(id: QRCodeCancel(), for: 0.3, scheduler: mainQueue)
      
    case .modifyAttendance(let attendanceId):
      return .run { send in
        let modifyAttendanceResult = await Result {
          try await attendanceUseCase.modifyAttendance(attendanceId: attendanceId)
        }
        
        switch modifyAttendanceResult {
        case .success(let modifyAttendanceData):
          if let modifyAttendanceData = modifyAttendanceData {
            await send(.inner(.modifyAttendanceResponse(.success(modifyAttendanceData))))
          }
          
        case .failure(let error):
          await send(.inner(.modifyAttendanceResponse(.failure(.encodingError(error.localizedDescription)))))
        }
      }
      .debounce(id: QRCodeCancel(), for: 0.3, scheduler: mainQueue)
    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .qrCodeValidateReponse(let result):
      switch result {
      case .success(let qrCodeValidateData):
        state.attendanceCheckModel =  qrCodeValidateData
        
      case .failure(let error):
        #logNetwork("qr 검증 실패", error.localizedDescription)
      }
      return .none
      
    case .filterScheduleReponse(let result):
      switch result {
      case .success(let filterScheduleData):
        state.sceduleFilterModel = filterScheduleData
        state.scheduleId = filterScheduleData.data.first?.id ?? ""
      case .failure(let error):
        #logNetwork("스케줄 필터 실패", error.localizedDescription)
      }
      return .none
      
    case .filterScheduleAttendanceReponse(let result):
      switch result {
      case .success(let filterScheduleAttendanceData):
        state.filterSceduleAttendanceModel = filterScheduleAttendanceData
      case .failure(let error):
        #logNetwork("출석 목록 필터 실패", error.localizedDescription)
      }
      return .none
      
    case .modifyAttendanceResponse(let result):
      switch result {
      case .success(let modifyAttendanceData):
        state.modifyAttendanceModel = modifyAttendanceData
        
        if modifyAttendanceData.data.status == .present {
          state.isPresent = true
        }
        
      case .failure(let error):
        #logNetwork("출석 수정 실패", error.localizedDescription)
      }
      return .none
    }
  }
}
