//
//  LoginView.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import AuthenticationServices

public struct LoginView: View {
  @Bindable var store: StoreOf<Login>
  
  public init(store: StoreOf<Login>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        Spacer()
          .frame(height: UIScreen.screenHeight * 0.3)
        
        logoImageView()
        
        socailLoginButton()
        
      }
    }
  }
}

extension LoginView {
  
  @ViewBuilder
  private func logoImageView() -> some View {
    VStack {
      Image(asset: .appLogo)
        .resizable()
        .scaledToFit()
        .frame(width: 65, height: 72)
      
      Spacer()
    }
  }
  
  @ViewBuilder
  private func socailLoginButton() -> some View {
    VStack {
      Image(asset: .appleLogin)
        .resizable()
        .scaledToFit()
        .frame(height: 48)
        .overlay {
          SignInWithAppleButton(.signIn) { request in
              // 새 nonce 생성 및 설정
              let rawNonce = AppleLoginManger.shared.randomNonceString()
              store.nonce = rawNonce // `store.nonce`에 저장하여 일관성 유지

              // 요청에 nonce의 SHA-256 해시 값을 설정
              request.requestedScopes = [.email, .fullName]
              request.nonce = AppleLoginManger.shared.sha256(rawNonce)
          } onCompletion: { result in
              // `store.nonce`를 액션에 전달
              store.send(.async(.appleLogin(result, nonce: store.nonce)))
          }
            .blendMode(.overlay)
            .signInWithAppleButtonStyle(.white)
            .frame(height: 30)
            .padding(.horizontal, 20)
        }
      
      
      Spacer()
        .frame(height: 8)
      
      Image(asset: .googleLogin)
        .resizable()
        .scaledToFit()
        .frame(height: 48)
        .onTapGesture {
          store.send(.async(.googleLogin))
        }
      
      Spacer()
        .frame(height: 40)
    }
    .padding(.horizontal, 20)
  }
}
 
