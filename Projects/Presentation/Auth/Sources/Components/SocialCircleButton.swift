//
//  SocialCircleButton.swift
//  Auth
//
//  Created by Wonji Suh  on 12/19/25.
//

import SwiftUI
import AuthenticationServices
import ComposableArchitecture

struct SocialCircleButtonView: View {
  @State var store: StoreOf<Login>
  let type: SocialType
  let onTap: () -> Void

  private let circleSize: CGFloat = 44

  @ViewBuilder
  var body: some View {
    switch type {
    case .apple:
      ZStack {
        Circle()
          .fill(.black)
          .frame(width: circleSize, height: circleSize)
          .shadow(color: .gray40, radius: 5, x: 0, y: 0)

        Image(systemName: type.image)
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 30)
          .foregroundColor(.white)

        SignInWithAppleButton(.signIn) { request in
          store.send(.async(.prepareAppleRequest(request)))
        } onCompletion: { result in
          store.send(.async(.appleLogin(result, nonce: store.nonce)))
        }
        .frame(width: circleSize, height: circleSize)
        .clipShape(Circle())
        .opacity(0.02)
        .allowsHitTesting(true)
      }

    case .google:
      Button(action: onTap) {
        Circle()
          .fill(.white)
          .overlay(Circle().stroke(.gray40, lineWidth: 1))
          .frame(width: circleSize, height: circleSize)
          .shadow(color: .gray40, radius: 5, x: 0, y: 0)
          .overlay(
            Image(assetName: type.image)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
          )
      }
      .buttonStyle(.plain)
        
    case .none:
      EmptyView()
    }
  }
}
