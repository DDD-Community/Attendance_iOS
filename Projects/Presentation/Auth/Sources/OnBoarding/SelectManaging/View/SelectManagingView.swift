//
//  OnBoardingSelectManagingView.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import SDWebImageSwiftUI

public struct SelectManagingView: View {
  @Bindable var store: StoreOf<SelectManagingReducer>
  var backAction: () -> Void = {}
  
  public init(
    store: StoreOf<SelectManagingReducer>,
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

        if store.loading {
          VStack {
            Spacer()

            AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
              .resizable()
              .scaledToFit()
              .frame(width: 200, height: 200)

            Spacer()
          }
        } else {
          selectManagingList()

          signUpSelectMangeButton()
        }

      }
      .onAppear {
        store.userSession.managing = []
        store.send(.view(.onAppear))
      }
    }
  }
}


extension SelectManagingView {
  
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
          ForEach(store.selectMangers ?? [], id: \.managingKeys) { item in
            SelectPartItem(
              content: item.managing.desc,
              isActive: store.userSession.managing.contains(item.managing)) {

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
          if store.userSession.managing.contains(.teamManaging) {
            store.send(.navigation(.presentSelectTeam))
          } else {
            store.send(.async(.signUpUser))
          }
        },
        title: store.userSession.managing.contains(.teamManaging) ? "다음" : "가입완료",
        config: CustomButtonConfig.create(),
        isEnable: store.activeButton
      )
      
      Spacer()
      
    }
    .padding(.horizontal, 24)
  }
}
