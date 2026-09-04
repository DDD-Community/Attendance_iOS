//
//  SelectManagingView.swift
//  Presentation
//
//  Created by DDD on 11/3/24.
//

import DDDSharedUI
import DDDCoreUI
import SwiftUI
import DDDDesignKit
import ComposableArchitecture
import DDDAnimation

@ViewAction(for: SelectManagingFeature.self)
public struct SelectManagingView: View {
  @Bindable public var store: StoreOf<SelectManagingFeature>
  var backAction: () -> Void = {}
  
  public init(
    store: StoreOf<SelectManagingFeature>,
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

        if store.viewState == .loading {
          VStack {
            Spacer()

            DDDAnimationView(.loading, isAnimating: .constant(store.viewState == .loading))
              .frame(width: 200, height: 200)

            Spacer()
          }
        } else {
          selectManagingList()

          signUpSelectManageButton()
        }

      }
      .alert($store.scope(state: \.alert, action: \.scope.alert))
      .onAppear {
        store.userSession.managing = []
        send(.onAppear)
      }
    }
  }
}


extension SelectManagingView {
  
  @ViewBuilder
  private func signUpSelectManagingText() -> some View {
    SignUpPartText(
      content: "담당 업무를 선택해주세요",
      title: "프로젝트 참여하시는 직무를 선택해 주세요.",
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
          ForEach(store.selectMangers, id: \.managingKeys) { item in
            SelectPartItem(
              content: item.managing.desc,
              isActive: store.userSession.managing.contains(item.managing)) {

                send(.selectManagingButton(selectManaging: item))
              }
          }
        }
      }
      .scrollIndicators(.hidden)
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }
  
  
  @ViewBuilder
  private func signUpSelectManageButton() -> some View {
    VStack {
      Spacer()
      
      CustomButton(
        action: {
          if store.userSession.managing.contains(.teamManaging) || store.userSession.userRole == .manager {
            store.send(.delegate(.presentSelectTeam))
          } else {
            send(.signUp)
          }
        },
        title: (store.userSession.managing.contains(.teamManaging) || store.userSession.userRole == .manager) ? "다음" : "가입완료",
        config: CustomButtonConfig.create()
      )
      .isEnable(!store.userSession.managing.isEmpty)
      
      Spacer()
      
    }
    .padding(.horizontal, 24)
  }
}
