//
//  SignUpInviteCodeView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/2/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct SignUpInviteCodeView : View {
  @Bindable var store: StoreOf<SignUpInviteCode>
  var backAction: ()  -> Void = {}

  public init(
    store: StoreOf<SignUpInviteCode>,
    backAction: @escaping () -> Void
  ) {
    self.store = store
    self.backAction = backAction
  }
  
  public var body: some View {
    ZStack {
      Color.backGround
        .edgesIgnoringSafeArea(.all)
      
      
      VStack {
        
        Spacer()
          .frame(height: 12)
        
        NavigationBackButton(buttonAction: backAction)
        
        ScrollView{
          inviteCodeInPutTextView()
          
          checkInviteCodeButton()
          
          Spacer()
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        
      }
    }
  }
}


extension SignUpInviteCodeView {
  
  @ViewBuilder
  private func inviteCodeInPutTextView() -> some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 40)
      
    
      Text("초대 코드를 입력해 주세요")
        .pretendardCustomFont(textStyle: .tilte1NormalBold)
        .foregroundStyle(Color.basicWhite)
      
      Spacer()
        .frame(height: 8)
      
      Text("가입을 위해 신규 기수 초대 코드가 필요합니다.")
        .pretendardCustomFont(textStyle: .body3NormalMedium)
        .foregroundStyle(Color.basicWhite)
      
      Text("받으신 4자리 초대 코드를 입력해 주세요.")
        .pretendardCustomFont(textStyle: .body3NormalMedium)
        .foregroundStyle(Color.basicWhite)
      
    }
  }
  
  
  @ViewBuilder
  private func checkInviteCodeButton() -> some View {
    VStack {
      Spacer()
        .frame(height: UIScreen.screenHeight * 0.65)
      
      CustomButton(
        action: {},
        title: "다음",
        config: CustomButtonConfig.create(),
        isEnable: false
      )
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 30)
  }
}
