//
//  CreateAppView.swift
//  Presentation
//
//  Created by Wonji Suh  on 4/6/25.
//

import SwiftUI

import ComposableArchitecture
import SwiftUIX
import Model
import DesignSystem

struct CreateAppView: View {
  @Bindable private var store: StoreOf<CreateApp>
  private var closeAction:() -> Void = { }
  
  init(
    store: StoreOf<CreateApp>,
    closeAction: @escaping () -> Void
  ) {
    self.store = store
    self.closeAction = closeAction
  }
  
  var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        createAppHeaderView()
        
        createAppFooterView()
        
        closeButton()
        
        Spacer()
          .frame(height: 40)
      }
    }
  }
}

extension CreateAppView {
  
  @ViewBuilder
  fileprivate func createAppHeaderView() -> some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 16)
      
      Text("만든 사람들")
        .pretendardCustomFont(textStyle: .title2NormalBold)
        .foregroundStyle(.staticWhite)
      
    }
  }
  
  @ViewBuilder
  fileprivate func createAppFooterView() -> some View {
    VStack(spacing: .zero) {
      createAppPartItem(
        selectPart: .pm,
        creators: "이경서, 최현희"
      )

      createAppPartItem(
        selectPart: .design,
        creators: "강동길, 이지윤, 조재인"
      )

      createAppPartItem(
        selectPart: .iOS,
        creators: "서원지, 홍은표"
      )
      
      createAppPartItem(
        selectPart: .android,
        creators: "심은석, 오세민, 이상훈"
      )
      
      createAppPartItem(
        selectPart: .server,
        creators: "조승준, 조지원, 이준석"
      )
      
    }
  }
  
  @ViewBuilder
  fileprivate func createAppPartItem(
    selectPart: SelectPart,
    creators: String
  ) -> some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 24)
      
      Text(selectPart.attendanceListDesc)
        .pretendardCustomFont(textStyle: .body3NormalRegular)
        .foregroundStyle(.staticWhite)
      
      Spacer()
        .frame(height: 2)
      
      Text(creators)
        .pretendardCustomFont(textStyle: .title3NormalMedium)
        .foregroundStyle(.staticWhite)
      
    }
    
  }
  
  @ViewBuilder
  fileprivate func closeButton() -> some View {
    VStack {
      Spacer()
        .frame(height: 36)
      
      
      CustomButton(
        action: closeAction,
        title: "닫기",
        config: CustomButtonConfig.createDateButton(),
        isEnable: true
      )
      .padding(.horizontal, 24)
    }
    
  }
}
