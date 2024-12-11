//
//  SignUpSelectMangingView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Model

public struct SignUpSelectMangingView: View {
  @Bindable var store: StoreOf<SignUpSelectManging>
  var backAction: () -> Void = {}
  
  public init(
    store: StoreOf<SignUpSelectManging>,
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
        
        signUpSelectMangingText()
        
        selectMangingList()
        
        signUpSelectMangeButton()
        
      }
    }
  }
}


extension SignUpSelectMangingView {
  
  @ViewBuilder
  private func signUpSelectMangingText() -> some View {
    SignUpPartText(
      content: "담당 업무를 선택해주세요",
      title: "프로젝트 참여하시는 직무을 선택해 주세요.",
      subtitle: ""
    )
  }
  
  @ViewBuilder
  private func selectMangingList() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      ScrollView {
        VStack {
          ForEach(Managing.mangingList, id: \.self) { item in
            SelectPartItem(
              content: item.mangingDesc,
              isActive: item == store.selectMangingPart) {
                store.send(.view(.selectMangingButton(selectManging: item)))
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
