//
//  LoginView.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import AuthenticationServices
import SwiftUI

import DesignSystem

import ComposableArchitecture

public struct LoginView: View {
  @Bindable private var store: StoreOf<Login>
  
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
        
        socialLoginButton()
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
  private func socialLoginButton() -> some View {
    VStack {
      HStack(alignment: .center, spacing: 24) {
        ForEach(SocialType.allCases.filter { $0 != .none }) { type in
          SocialCircleButtonView(
            store: store,
            type: type
          ) {
            store.send(.view(.signInWithSocial(social: type)))
          }
        }
      }

      Spacer()
        .frame(height: 40)
      
    }
    .padding(.horizontal, 20)
  }
}


#Preview {
  LoginView(
    store: .init(
      initialState: Login.State(),
      reducer: {
        Login()
      })
  )
}
