//
//  SignUpSelectTeamView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/4/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Model

public struct SignUpSelectTeamView: View {
  @Bindable var store: StoreOf<SignUpSelectTeam>
  var backAction: () -> Void
  
  public init(
    store: StoreOf<SignUpSelectTeam>,
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
        
        signUpSelectTeamText()
        
        selectTeamList()
        
        signUpSelectTeamButton()
      }
    }
  }
}

extension SignUpSelectTeamView {
  
  @ViewBuilder
  private func signUpSelectTeamText() -> some View {
    SignUpPartText(
      content: "팀을 선택해주세요",
      title: "프로젝트 참여하시는 팀을 선택해 주세요.",
      subtitle: ""
    )
  }
  
  @ViewBuilder
  private func selectTeamList() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      ScrollView {
        VStack {
          ForEach(SelectTeam.teamList, id: \.self) { item in
            SelectTeamIteam(
              content: item.selectTeamDesc,
              isActive:  item == store.selectTeam) {
                store.send(.view(.selectTeamButton(selectTeam: item)))
              }
          }
        }
      }
      .scrollIndicators(.hidden)
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }
  
  @ViewBuilder
  private func signUpSelectTeamButton() -> some View {
    VStack {
      Spacer()
      
      CustomButton(
        action: {
          store.send(.async(.signUpMember))
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
