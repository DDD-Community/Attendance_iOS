//
//  SignUpPartView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import Networkings

public struct SignUpPartView: View {
  @Bindable var store: StoreOf<SignUpPart>
  var backAction: () -> Void = {}
  
  public init(
    store: StoreOf<SignUpPart>,
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
        
        StepNavigationBar(activeStep: 2, buttonAction: backAction)
        
        signUpPartText()
        
        selectPartList()
        
        signUpPartButton()
        
      }
    }
  }
}

extension SignUpPartView {
  
  @ViewBuilder
  private func signUpPartText() -> some View {
    SignUpPartText(
      content: "직무를 선택해 주세요",
      title: "프로젝트 참여하시는 직무을 선택해 주세요.",
      subtitle: ""
    )
  }
  
  
  @ViewBuilder
  private func selectPartList() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      ScrollView {
        VStack {
          ForEach(SelectPart.allParts, id: \.self) { item in
            SelectPartItem(
              content: item.desc,
              isActive: item == store.selectPart) {
                store.send(.view(.selectPartButton(selectPart: item)))
              }
          }
        }
      }
      .scrollIndicators(.hidden)
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }
  
  
  
  @ViewBuilder
  private func signUpPartButton() -> some View {
    VStack {
      Spacer()
      
      CustomButton(
        action: {
          store.send(.navigation(.presntNextStep))
        },
        title: "다음",
        config: CustomButtonConfig.create(),
        isEnable: store.activeSelectPart
      )
      
      Spacer()
        .frame(height: 20)
    }
    .padding(.horizontal, 24)
  }
}


