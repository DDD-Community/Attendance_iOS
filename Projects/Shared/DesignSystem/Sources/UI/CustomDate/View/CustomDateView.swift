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
        
        VStack {
          customDateHeaderTitle()
          
          monthDateView()
          
          customCalanderVIew()
          
          selectDateButton()
        }
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
  
  @ViewBuilder
  fileprivate func monthDateView() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 16)
      
      HStack {
        Image(systemName: "chevron.left")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 15)
          .foregroundStyle(.basicBlack)
          .onTapGesture {
            store.send(.view(.movePreviousMonth))
          }
        
        Spacer()

        
        Text(store.nowDate.toFormattedString()) // 현재 날짜를 보여줌
          .pretendardCustomFont(textStyle: .body1NormalMedium)
          .foregroundStyle(.basicBlack)
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 15)
          .foregroundStyle(.basicBlack)
          .onTapGesture {
            store.send(.view(.moveNextMonth))
          }
      }
      .padding(.horizontal, 20)
    }
  }
  
  @ViewBuilder
  fileprivate func customCalanderVIew() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 10)
      
      CustomFSCalendarView(
        selectDate: $selectDate,
        currentMonth: $store.nowDate,
        isDateSelected: $store.dateSelected)
        .frame(height: 310)
    }
  }
  
  @ViewBuilder
  fileprivate func selectDateButton() -> some  View {
    LazyVStack {
      Spacer()
        .frame(height: 20)
      
      CustomButton(
        action: {
          if store.dateSelected {
            selectAction()
          }
        },
        title: "확인",
        config: CustomButtonConfig.createDateButton(),
        isEnable: store.dateSelected
      )
      .padding(.horizontal, 20)
      
      Spacer()
        .frame(height: 40)
    }
  }
  
}
