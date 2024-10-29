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
      Color.backGround
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
              var appleNonce = store.nonce
              appleNonce = AppleLoginManger.shared.randomNonceString()
              request.requestedScopes = [.email, .fullName]
              request.nonce = AppleLoginManger.shared.sha256(appleNonce)
            } onCompletion: { result in
               
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
      
      Spacer()
        .frame(height: 40)
    }
    .padding(.horizontal, 20)
  }
}
 
