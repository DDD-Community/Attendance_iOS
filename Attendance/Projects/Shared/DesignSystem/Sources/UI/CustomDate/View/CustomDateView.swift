//
//  CustomDateView.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 2/8/25.
//

import SwiftUI

import SwiftUIX
import ComposableArchitecture

public struct CustomDateView: View {
  @Bindable private var store: StoreOf<CustomDate>
  @Binding private var selectDate: Date
  private var selectAction: () -> Void
  
   public init(
    store: StoreOf<CustomDate>,
    selectDate: Binding<Date>,
    selectAction: @escaping () -> Void
  ) {
    self.store = store
    self._selectDate = selectDate
    self.selectAction = selectAction
  }
  
  
  
  public var body: some View {
    LazyView {
      ZStack {
        Color.staticWhite
          .edgesIgnoringSafeArea(.all)
      }
    }
  }
}

extension CustomDateView {
  
  @ViewBuilder
  fileprivate func customDateHeaderTitle() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 32)
      
      Text("날짜 선택")
        .pretendardCustomFont(textStyle: .tilte1NormalMedium)
        .foregroundStyle(.borderInverse)
      
    }
  }
  
//  @ViewBuilder
//  private func monthDateView() -> some View {
//    HStack {
//      Spacer()
//        .frame(width: 20)
//      
//      Image(systemName: "chevron.left")
//        .resizable()
//        .scaledToFit()
//        .frame(width: 20, height: 15)
//        .foregroundStyle(.basicBlack)
//        .onTapGesture {
//          store.send(.view(.movePreviousMonth))
//        }
//      
//      Spacer()
//        .frame(width: 5)
//      
//      Text(store.nowDate.toFormattedString()) // 현재 날짜를 보여줌
//        .pretendardFont(family: .SemiBold, size: 14)
//        .foregroundStyle(.basicBlack)
//      
//      Spacer()
//        .frame(width: 5)
//      
//      Image(systemName: "chevron.right")
//        .resizable()
//        .scaledToFit()
//        .frame(width: 20, height: 15)
//        .foregroundStyle(.basicBlack)
//        .onTapGesture {
//          store.send(.view(.moveNextMonth))
//        }
//      
//      Spacer()
//    }
//    .padding(.horizontal, 20)
//    
//  }
  
}
