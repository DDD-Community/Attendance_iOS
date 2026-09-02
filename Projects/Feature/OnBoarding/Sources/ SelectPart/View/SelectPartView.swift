//
//  SelectPartView.swift
//  Presentation
//
//  Created by DDD on 11/3/24.
//

import DDDSharedUI
import DDDCoreUI
import SwiftUI

import DDDDesignKit

import DDDAnimation
import ComposableArchitecture

@ViewAction(for: SelectPartReducer.self)
public struct SelectPartView: View {
  @Bindable public var store: StoreOf<SelectPartReducer>
  var backAction: () -> Void = {}
  
  public init(
    store: StoreOf<SelectPartReducer>,
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
        
        if store.loading {
          VStack {
            Spacer()

            DDDAnimationView(.loading, isAnimating: .constant(store.loading))
              .frame(width: 200, height: 200)

            Spacer()
          }
        } else {
          selectPartList()

          signUpPartButton()
        }

      }
      .task {
        send(.onAppear)
      }
    }
  }
}

extension SelectPartView {

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
        LazyVStack {
          ForEach(
            (store.selectJobs ?? []).sorted {
              $0.job.desc.localizedCaseInsensitiveCompare($1.job.desc) == .orderedAscending
            },
            id: \.jobKeys
          ) { item in
            SelectPartItem(
              content: item.job.desc,
              isActive: item.job == store.selectPart
            ) {
              send(.selectPartButton(selectPart: item))
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
          store.send(.navigation(.presentNextStep))
        },
        title: "다음",
        config: CustomButtonConfig.create()
      )
      .isEnable(store.activeSelectPart)
      
      Spacer()
        .frame(height: 20)
    }
    .padding(.horizontal, 24)
  }
}


