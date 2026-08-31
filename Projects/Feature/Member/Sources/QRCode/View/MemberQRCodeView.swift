//
//  QRCodeView.swift
//  Presentation
//
//  Created by DDD on 5/18/25.
//

import SwiftUI

import DDDDesignKit

import ComposableArchitecture

struct MemberQRCodeView: View {
  @Bindable private var store: StoreOf<MemberQRCode>
  private var backAction: () -> Void

  init(store: StoreOf<MemberQRCode>, backAction: @escaping () -> Void) {
    self.store = store
    self.backAction = backAction
  }

  var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      navigationBar

      content

      Spacer()
    }
    .background(.backGroundPrimary)
    .onAppear {
      store.send(.view(.onAppear))
    }
  }

  private var navigationBar: some View {
    HStack {
      Button(action: backAction) {
        Image(asset: .arrowBackWhite)
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 20)
      }
      .frame(width: 28, height: 28)

      Spacer()
    }
    .frame(height: 52)
    .padding(.leading, 16)
  }

  private var content: some View {
    VStack(alignment: .center, spacing: 32) {
      VStack(alignment: .center, spacing: 6) {
        Text("QR 코드를 스캔해 주세요.")
          .dddFont(.title2NormalBold)
          .foregroundStyle(.textPrimary)

        Text("스캔 시 자동으로 출석이 인정됩니다.")
          .dddFont(.body3NormalMedium)
          .foregroundStyle(.textSecondary)
      }

      if let image = store.qrCodeImage {
        image
          .interpolation(.none)
          .resizable()
          .scaledToFit()
          .frame(width: 270, height: 270)
          .padding(10)
          .background(.white)
          .cornerRadius(24)
      }
    }
    .padding(.top, 64)
    .frame(maxWidth: .infinity)
  }
}
