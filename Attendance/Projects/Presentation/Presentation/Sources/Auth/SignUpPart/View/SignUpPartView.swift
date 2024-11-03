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
      Color.backGround
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        Spacer()
          .frame(height: 14)
        
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
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 40)
      
      Text("직무를 선택해 주세요")
        .pretendardCustomFont(textStyle: .tilte1NormalBold)
        .foregroundStyle(Color.basicWhite)
      
      Spacer()
        .frame(height: 8)
      
      Text("프로젝트 참여하시는 직무을 선택해 주세요.")
        .pretendardCustomFont(textStyle: .body3NormalMedium)
        .foregroundStyle(Color.basicWhite)
      
    }
  }
  
  
  @ViewBuilder
  private func selectPartList() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      VStack {
        ForEach(SelectPart.allParts, id: \.self) { item in
              selectPartItem(content: item.desc, completion: {
                  store.send(.view(.selectPartButton(selectPart: item)))
              }, isActive: item == store.selectPart)
          }
      }
    }
  }
  
  @ViewBuilder
  private func selectPartItem(
    content: String,
    completion: @escaping () -> Void,
    isActive: Bool
  ) -> some View {
    VStack {
      RoundedRectangle(cornerRadius: 16)
        .stroke(isActive ? Color.blue40 : Color.clear, style: .init(lineWidth: 2))
        .frame(height: 58)
        .background(Color.gray90)
        .cornerRadius(16)
        .overlay {
          HStack {
            Text(content)
              .pretendardCustomFont(textStyle: .body1NormalMedium)
              .foregroundStyle(Color.grayWhite)
            
            Spacer()
            
            Image(asset: isActive ? .activeSelectPart : .disableSelectPart)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
          }
          .padding(.horizontal, 20)
          .onTapGesture {
            completion()
          }
        }
        .onTapGesture {
          completion()
        }
    }
    .padding(.horizontal, 24)
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
  
  
