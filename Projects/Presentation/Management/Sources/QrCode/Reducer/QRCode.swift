//
//  QRCode.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation

import Shareds

import ComposableArchitecture
import LogMacro

@Reducer
public struct QRCode {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var scannedText = ""
    var isScanning = true
    let scannerSize: CGFloat = 240
    var isPresent: Bool = false

    var qrCheckModel: QRValidateModel?
    var scheduleId: String = ""
    var nowDate = Date()
    var isUseQRCode: Bool = false

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
  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case qrCodeValidateReponse(Result<QRValidateModel, CustomError>)
  }

  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {


  }

  private struct QRCodeCancel: Hashable {}

  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue

  @Dependency(\.qrCodeUseCase) var qrCodeUseCase

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
}

extension QRCode {
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

            if qrCodeValidateData.code == 200  {
              await send(.view(.stopScanning))
            }
          }

        case .failure(let error):
          await send(.inner(.qrCodeValidateReponse(.failure(.encodingError(error.localizedDescription)))))
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
        state.qrCheckModel = qrCodeValidateData
        state.isUseQRCode = false
      case .failure(let error):
        #logNetwork("qr 검증 실패", error.localizedDescription)
        state.isUseQRCode = true
      }
      return .none

    }
  }
}
