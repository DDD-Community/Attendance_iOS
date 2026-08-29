//
//  SelectTeamView.swift
//  Presentation
//
//  Created by DDD on 11/4/24.
//

import DDDSharedUI
import DDDCoreUI
import SwiftUI

import DDDDesignKit

import ComposableArchitecture
import SDWebImageSwiftUI

@ViewAction(for: SelectTeam.self)
public struct SelectTeamView: View {
  @Bindable public var store: StoreOf<SelectTeam>
  var backAction: () -> Void
  
  public init(
    store: StoreOf<SelectTeam>,
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


        if store.loading {
          VStack {
            Spacer()

            AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(store.loading))
              .resizable()
              .scaledToFit()
              .frame(width: 200, height: 200)

            Spacer()
          }
        } else {
          selectTeamList()

          signUpSelectTeamButton()
        }
      }
      .onAppear {
        store.userSession.selectTeam = .unknown
        send(.onAppear)
      }
      .alert($store.scope(state: \.alert, action: \.scope.alert))
    }
  }
}

extension SelectTeamView {
  
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
          ForEach(store.teams ?? [], id: \.teamId) { item in
            SelectTeamIteam(
              content: item.teams.selectTeamDescription,
              isActive: item.teams == store.userSession.selectTeam) {
                send(.selectTeamButton(selectTeam: item))
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
          send(.signUp)
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
