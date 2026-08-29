//
//  QRCode.swift
//  DDDAttendance
//
//  Created by DDD on 6/11/24.
//

import Foundation

import DDDSharedUI
import Entity

import ComposableArchitecture
import LogMacro
import Vision
import UIKit

@Reducer
public struct QRCode {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var scannedText = ""
    var isScanning = true
    let scannerSize: CGFloat = 240
    var isPresent: Bool = false

    var qrCheckModel: QRValidateEntity?
    var scheduleId: String = ""
    var nowDate = Date()
    var isUseQRCode: Bool = false
    @Presents public var alert: AlertState<AlertAction>?

    public init() {}
  }

  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case scope(ScopeAction)
    case navigation(NavigationAction)

  }

  //MARK: - ViewAction
  @CasePathable
  public enum View {
    case stopScanning
  }

  @CasePathable
  public enum ScopeAction {
    case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }


  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case qrCodeValidate
  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case qrCodeValidateResponse(Result<QRValidateEntity, AttendanceError>)
  }

  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {


  }

  private struct QRCodeCancel: Hashable {}

  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue

  @Dependency(\.qrCodeUseCase) var qrCodeUseCase

  public var body: some Reducer<State, Action> {
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

        case .scope(let scopeAction):
          switch scopeAction {
          case .alert:
            return .none
          }
      }
    }
    .ifLet(\.$alert, action: \.scope.alert)
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
          try await qrCodeUseCase.qrValidateCheck(from: scannedText)
        }
          .mapError(AttendanceError.from)
        return await send(.inner(.qrCodeValidateResponse(qrCodeValidateResult)))
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
    case .qrCodeValidateResponse(let result):
      switch result {
      case .success(let qrCodeValidateData):
        state.qrCheckModel = qrCodeValidateData
        state.isUseQRCode = false

          if qrCodeValidateData.isSuccess {
            return .send(.view(.stopScanning))
          } else {
            return .none
          }


      case .failure(let error):
        #logNetwork("qr 검증 실패", error.localizedDescription)
        state.isUseQRCode = true
          // 서버에서 온 사용자 친화적 메시지 사용
          let alertTitle: String
          let alertMessage: String

          switch error {
          case .unknown(let message):
            // 서버에서 온 상세 메시지 (예: "출석일이 아닙니다")
            alertTitle = "QR 출석실패"
            alertMessage = message
          case .serverError(let code):
            alertTitle = "서버 오류"
            alertMessage = "서버에 문제가 발생했습니다. (코드: \(code))\n잠시 후 다시 시도해주세요."
          case .networkError(let message):
            alertTitle = "네트워크 오류"
            alertMessage = "인터넷 연결을 확인하고 다시 시도해주세요.\n\(message)"
          case .unauthorized:
            alertTitle = "인증 실패"
            alertMessage = "로그인이 필요합니다. 다시 로그인해주세요."
          default:
            alertTitle = "QR 인식 실패"
            alertMessage = error.errorDescription ?? "QR 코드를 다시 스캔해 주세요"
          }

          state.alert = AlertState {
            TextState(alertTitle)
          } actions: {
            ButtonState(action: .confirmTapped) {
              TextState("확인")
            }
          } message: {
            TextState(alertMessage)
          }
          return .none
      }

    }
  }

  // MARK: - Base64 이미지 감지
  private func isBase64Image(_ text: String) -> Bool {
    // 1. data:image URL 스킴 확인
    if text.hasPrefix("data:image") {
      return true
    }

    // 2. 길이 확인 (이미지 Base64는 보통 100자 이상)
    guard text.count > 100 else {
      return false
    }

    // 3. 다양한 이미지 포맷의 Base64 시작 문자열 확인
    let imageBase64Prefixes = [
      "iVBORw0KGgo",           // PNG
      "/9j/4AAQ",              // JPEG (일반)
      "/9j/4",                 // JPEG (다른 형태)
      "R0lGODlh",              // GIF
      "UklGRg",                // WebP
      "Qk0",                   // BMP
      "SUkqAA",                // TIFF (Little Endian)
      "TU0AKg"                 // TIFF (Big Endian)
    ]

    for prefix in imageBase64Prefixes {
      if text.hasPrefix(prefix) {
        return true
      }
    }

    // 4. Base64 패턴 확인 (영숫자 + / + = 로만 구성되고 충분히 긴 경우)
    let base64Pattern = "^[A-Za-z0-9+/]*={0,2}$"
    if text.range(of: base64Pattern, options: .regularExpression) != nil && text.count > 500 {
      // 실제 이미지 디코딩 시도
      return isValidImageData(text)
    }

    return false
  }

  // 실제로 Base64 디코딩해서 이미지인지 확인
  private func isValidImageData(_ base64String: String) -> Bool {
    let cleanBase64 = base64String
      .replacingOccurrences(of: "data:image/png;base64,", with: "")
      .replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
      .replacingOccurrences(of: "data:image/gif;base64,", with: "")

    guard let imageData = Data(base64Encoded: cleanBase64),
          let _ = UIImage(data: imageData) else {
      return false
    }

    return true
  }

  // MARK: - Base64 QR 코드 디코딩
  private func decodeQRFromBase64(_ base64String: String) async -> String? {
    return await withCheckedContinuation { continuation in
      // Base64 문자열을 Data로 변환
      let cleanBase64 = base64String
        .replacingOccurrences(of: "data:image/png;base64,", with: "")
        .replacingOccurrences(of: "data:image/jpeg;base64,", with: "")

      guard let imageData = Data(base64Encoded: cleanBase64),
            let uiImage = UIImage(data: imageData),
            let cgImage = uiImage.cgImage else {
        #logNetwork("Base64 이미지 변환 실패", base64String.prefix(50))
        continuation.resume(returning: nil)
        return
      }

      // Vision을 사용해서 QR 코드 감지
      let request = VNDetectBarcodesRequest { request, error in
        if let error = error {
          #logNetwork("QR 디코딩 에러", error.localizedDescription)
          continuation.resume(returning: nil)
          return
        }

        guard let observations = request.results as? [VNBarcodeObservation],
              let firstBarcode = observations.first,
              let qrCodeContent = firstBarcode.payloadStringValue else {
          #logNetwork("QR 코드를 찾을 수 없음", "")
          continuation.resume(returning: nil)
          return
        }

        #logNetwork("QR 디코딩 성공", qrCodeContent)
        continuation.resume(returning: qrCodeContent)
      }

      // QR 코드만 감지하도록 설정
      request.symbologies = [.qr]

      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

      do {
        try handler.perform([request])
      } catch {
        #logNetwork("Vision 처리 실패", error.localizedDescription)
        continuation.resume(returning: nil)
      }
    }
  }
}
