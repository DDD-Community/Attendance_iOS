//
//  SignUpNameView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct SignUpNameView: View {
  @Bindable var store: StoreOf<SignUpName>
  var backAction: () -> Void = {}
  
  public init(
    store: StoreOf<SignUpName>,
    backAction: @escaping () -> Void
  ) {
    self.store = store
    self.backAction = backAction
  }
  
  
  public var body: some View {
    ZStack {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        
        Spacer()
          .frame(height: 12)
        
        StepNavigationBar(activeStep: 1, buttonAction: backAction)
        
        ScrollView {
          signUpNameText()
          
          signUpNameTextField()
          
          errorNameText()
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
          UIScrollView.appearance().bounces = false
        }
        
        signUpNameButton()
        
        Spacer()
          .frame(height: 20)
      }
      .onTapGesture {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
      }
    }
    .onTapGesture {
      UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
  }
}

extension SignUpNameView {
  
  @ViewBuilder
  private func signUpNameText() -> some View {
    SignUpPartText(
      content: "이름이 어떻게 되시나요?",
      title: "가입하실 때 사용할 이름을 입력해 주세요",
      subtitle: ""
    )
  }
  
  
  @ViewBuilder
  private func signUpNameTextField() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      RoundedRectangle(cornerRadius: 16)
        .inset(by: 0.5)
        .stroke(store.isNotAvaliableName ? .statusError : .borderInactive, lineWidth: 1)
        .frame(height: 56)
        .overlay {
          HStack {
            Spacer()
              .frame(width: 20)
            
            TextField("이름을 입력해주세요.", text: $store.userSignUpMember.name)
              .pretendardCustomFont(textStyle: .body2NormalMedium)
              .foregroundStyle(.grayWhite)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity)
              .onChange(of: store.userSignUpMember.name) { newValue, oldValue in
                if newValue.count > 5 {
                  store.userSignUpMember.name = String(newValue.prefix(5))
                  store.isNotAvaliableName = false
                }
              }
              .onSubmit {
                
              }
            
            Spacer()
            
            Image(asset: store.isNotAvaliableName ? .errorClose : .close)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .onTapGesture {
                store.userSignUpMember.name = ""
              }
            
            Spacer()
              .frame(width: 20)
          }
        }
      
    }
    .padding(.horizontal, 24)
  }
  
  @ViewBuilder
  private func errorNameText() -> some View {
    if store.isNotAvaliableName  {
      VStack {
        Spacer()
          .frame(height: 8)
        
        HStack {
          Label {
            Image(asset: .error)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
          } icon: {
            Text("5자 이내의 본명을 입력해주세요")
              .pretendardCustomFont(textStyle: .body3NormalMedium)
              .foregroundStyle(.statusError)
          }
        }
        
      }
      .padding(.horizontal, 24)
    }
  }
  
  
  @ViewBuilder
  private func signUpNameButton() -> some View {
    VStack {
      Spacer()
      
      CustomButton(
        action: {
          store.send(.view(.checkIsAvaliableName))
        },
        title: "다음",
        config: CustomButtonConfig.create(),
        isEnable: store.enableButton
      )
    }
    .padding(.horizontal, 24)
  }
  
}
