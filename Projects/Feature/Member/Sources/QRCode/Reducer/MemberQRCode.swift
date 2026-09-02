//
//  MemberQRCode.swift
//  Presentation
//
//  Created by DDD on 5/18/25.
//

import DDDCoreLogger
import Foundation
import SwiftUI

import Entity
import DDDSharedUI

import ComposableArchitecture
import MemberInterface

@Reducer
public struct MemberQRCode {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init() {}

    @ObservationStateIgnored
    var didAppear: Bool = false

    var qrCodeImage: SwiftUI.Image? = nil

    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case inner(InnerAction)
    case async(AsyncAction)
    case delegate(DelegateAction)
  }

  @CasePathable
  public enum View {
    case onAppear
  }

  public enum AsyncAction: Equatable {
    case createQRCode
    case generateQRCodeImage(String)
  }

  public enum InnerAction: Equatable {
    case onCreateQRCodeResponse(Result<String, QRCodeError>)
    case onGenerateQRCodeImage(Result<SwiftUI.Image?, QRCodeError>)
  }

  /// 이동 계약은 MemberInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = MemberQRCodeDelegate

  @Dependency(\.qrCodeUseCase) private var qrCodeUseCase

  public var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case let .view(action):
        return handleViewAction(state: &state, action: action)

      case let .inner(action):
        return handleInnerAction(state: &state, action: action)

      case let .async(action):
        return handleAsyncAction(state: &state, action: action)

      case let .delegate(action):
        return handleDelegateAction(state: &state, action: action)
      }
    }
  }
}

extension MemberQRCode {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      guard !state.didAppear else {
        return .none
      }

      state.didAppear = true

      return .run { send in
        await send(.async(.createQRCode))
      }
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .onCreateQRCodeResponse(result):
      switch result {
      case let .success(qrCodeString):
        DDDLogger.debug("succeed create QRCode: \(qrCodeString)", category: .attendance)
        return .run { send in
          await send(.async(.generateQRCodeImage(qrCodeString)))
        }

      case let .failure(error):
        DDDLogger.debug("failed create QRCode: \(error)", category: .attendance)
        return .none
      }

    case let .onGenerateQRCodeImage(result):
      switch result {
      case let .success(image):
        DDDLogger.debug("succeed generate QRCodeImage", category: .attendance)
        state.qrCodeImage = image
        return .none

      case let .failure(error):
        DDDLogger.debug("failed generate QRCodeImage: \(error)", category: .attendance)
        return .none
      }
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .createQRCode:
      let userID = state.userSession.userID
      return .run { send in
        let result = await Result {
          try await qrCodeUseCase.createQRCode(userID: userID)
        }

        switch result {
        case let .success(qrCodeString):
          await send(.inner(.onCreateQRCodeResponse(.success(qrCodeString))))

        case let .failure(error):
          let error = QRCodeError.from(error)
          await send(.inner(.onCreateQRCodeResponse(.failure(error))))
        }
      }

    case let .generateQRCodeImage(qrCodeString):
      return .run { send in
        let result = await Result { await qrCodeUseCase.generateQRCode(from: qrCodeString) }

        switch result {
        case let .success(image):
          await send(.inner(.onGenerateQRCodeImage(.success(image))))

        case let .failure(error):
          let error = QRCodeError.from(error)
          await send(.inner(.onGenerateQRCodeImage(.failure(error))))
        }
      }
    }
  }

  private func handleDelegateAction(
    state _: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .back:
      return .none
    }
  }
}
