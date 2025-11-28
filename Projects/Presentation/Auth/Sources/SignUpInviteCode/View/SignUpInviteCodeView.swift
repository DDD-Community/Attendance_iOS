//
//  SignUpInviteCodeView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/2/24.
//

import SwiftUI

import DesignSystem

import ComposableArchitecture
import SwiftUIX

public struct SignUpInviteCodeView : View {
  @Bindable var store: StoreOf<SignUpInviteCode>
  @FocusState var firstInviteCodeFocus: Bool
  @FocusState var secodInviteCodeFocus: Bool
  @FocusState var thirdlnviteCodeFocus: Bool
  @FocusState var lastlnviteCodeFocus: Bool
  var backAction: ()  -> Void = {}
  
  public init(
    store: StoreOf<SignUpInviteCode>,
    backAction: @escaping () -> Void
  ) {
    self.store = store
    self.backAction = backAction
  }
  
  public var body: some View {
    LazyView {
      ZStack {
        Color.backGroundPrimary
          .edgesIgnoringSafeArea(.all)
        
        VStack {
          
          Spacer()
            .frame(height: 12)
          
          NavigationBackButton(buttonAction: backAction)
          
          ScrollView{
            inviteCodeInPutTextView()
            
            inviteCodeView()
            
            isNotValidateCodeErrorText()
            
          }
          .scrollIndicators(.hidden)
          .scrollBounceBehavior(.basedOnSize)
          
          checkInviteCodeButton()
          
          Spacer()
            .frame(height: 20)
          
        }
        .onTapGesture {
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
          store.send(.view(.initInviteCode))
        }
      }
      
    }
  }
}


extension SignUpInviteCodeView {
  
  @ViewBuilder
  private func inviteCodeInPutTextView() -> some View {
    SignUpPartText(
      content: "초대 코드를 입력해 주세요",
      title: "가입을 위해 신규 기수 초대 코드가 필요합니다.",
      subtitle: "받으신 4자리 초대 코드를 입력해 주세요."
    )
  }
  
  
  @ViewBuilder
  private func checkInviteCodeButton() -> some View {
    VStack {
      Spacer()
      
      CustomButton(
        action: {
          store.send(.async(.validataInviteCode(code: store.totalInviteCode)))
        },
        title: "다음",
        config: CustomButtonConfig.create(),
        isEnable: store.enableButton
      )
    }
    .padding(.horizontal, 24)
    .fixedSize(horizontal: false, vertical: true)
  }
  
  @ViewBuilder
  private func inviteCodeView() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      HStack(spacing: 8) {
        Spacer()
        
        inputCodeText(
          text: $store.firstInviteCode,
          isErrorCode: store.isNotAvaliableCode,
          isFocs: $firstInviteCodeFocus) { moveBack in
            if moveBack {
              firstInviteCodeFocus = true
              store.isNotAvaliableCode = false
            } else {
              secodInviteCodeFocus = true
            }
          }
        
        inputCodeText(
          text: $store.secondInviteCode,
          isErrorCode:  store.isNotAvaliableCode,
          isFocs: $secodInviteCodeFocus) { moveBack in
            if moveBack {
              firstInviteCodeFocus = true
              store.isNotAvaliableCode = false
            } else {
              thirdlnviteCodeFocus = true
            }
          }
        
        inputCodeText(
          text: $store.thirdInviteCode,
          isErrorCode:  store.isNotAvaliableCode,
          isFocs: $thirdlnviteCodeFocus) { moveBack in
            if moveBack {
              secodInviteCodeFocus = true
              store.isNotAvaliableCode = false
            } else {
              lastlnviteCodeFocus = true
            }
          }
        
        inputCodeText(
          text: $store.lastInviteCode,
          isErrorCode: store.isNotAvaliableCode,
          isFocs: $lastlnviteCodeFocus) { moveBack in
            if moveBack {
              thirdlnviteCodeFocus = true
              store.isNotAvaliableCode = false
            }
          }
        
        Spacer()
      }
      .padding(.horizontal, 24)
    }
  }
  
  @ViewBuilder
  private func inputCodeText(
    text: Binding<String>,
    isErrorCode: Bool,
    isFocs: FocusState<Bool>.Binding,
    completion: @escaping (Bool) -> Void
  ) -> some View {
    RoundedRectangle(cornerRadius: 16)
      .stroke(
        text.wrappedValue.isEmpty ? .blue20 :
        isErrorCode ? .red40 : Color.clear,
        style: .init(lineWidth: text.wrappedValue.isEmpty ? 1.5 : 2)
      )
      .background(
        text.wrappedValue.isEmpty ? Color.clear :
        isErrorCode ? .red10 : .blue10
      )
      .cornerRadius(16)
      .frame(width: 64, height: 64)
      .overlay {
        TextField("", text: text)
          .pretendardCustomFont(textStyle: .headline7Semibold)
          .foregroundStyle(.gray90)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .keyboardType(.numberPad)
          .focused(isFocs)
          .onChange(of: text.wrappedValue) { _, newValue in
            if newValue.count > 1 {
              text.wrappedValue = String(newValue.prefix(1))
            }

            if newValue.count == 1 {
              DispatchQueue.main.async {
                completion(false) // 다음 칸으로 이동
              }
            } else if newValue.isEmpty {
              DispatchQueue.main.async {
                completion(true) // 이전 칸으로 이동
              }
            }
          }
      }
  }

  @ViewBuilder
  private func isNotValidateCodeErrorText() -> some View {
    if store.isNotAvaliableCode {
      VStack {
        Spacer()
          .frame(height: 16)
        
        HStack {
          Spacer()
          Image(asset: .error)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
          
          Spacer()
            .frame(width: 4)
          
          
          Text("코드가 유효하지 않습니다.")
            .pretendardCustomFont(textStyle: .body1NormalMedium)
            .foregroundStyle(Color.statusError)
          
          Spacer()
        }
      }
    }
  }
}
