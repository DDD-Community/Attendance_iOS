//
//  SignUpSelectManagingView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Model

public struct SignUpSelectManagingView: View {
  @Bindable var store: StoreOf<SignUpSelectManaging>
  var backAction: () -> Void = {}
  
  public init(
    store: StoreOf<SignUpSelectManaging>,
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
        
        StepNavigationBar(activeStep: 3, buttonAction: backAction)
        
        signUpSelectManagingText()
        
        selectManagingList()
        
        signUpSelectMangeButton()
        
      }
    }
  }
}


extension SignUpSelectManagingView {
  
  @ViewBuilder
  private func signUpSelectManagingText() -> some View {
    SignUpPartText(
      content: "담당 업무를 선택해주세요",
      title: "프로젝트 참여하시는 직무을 선택해 주세요.",
      subtitle: ""
    )
  }
  
  @ViewBuilder
  private func selectManagingList() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      ScrollView {
        VStack {
          ForEach(Managing.managingList, id: \.self) { item in
            SelectPartItem(
              content: item.managingDesc,
              isActive: item == store.selectManagingPart) {
                store.send(.view(.selectManagingButton(selectManaging: item)))
              }
          }
        }
      }
      .scrollIndicators(.hidden)
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }
  
  @ViewBuilder
  private func signUpSelectMangeButton() -> some View {
    VStack {
      Spacer()
      
      CustomButton(
        action: {
          store.send(.async(.signUpCoreMember))
        },
        title: "가입 완료",
        config: CustomButtonConfig.create(),
        isEnable: store.activeButton
      )
      
      Spacer()
      
    }
    .padding(.horizontal, 24)
  }
}
