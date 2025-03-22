//
//  CoreMemberMainView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import SwiftUI

import DesignSystem
import Model

import ComposableArchitecture
import SDWebImageSwiftUI

struct CoreMemberMainView: View {
  @Bindable var store: StoreOf<CoreMember>
  @State var isExpanded: Bool = false
  @State private var selectedItem = "출석"
  
  init(store: StoreOf<CoreMember>) {
    self.store = store
  }
  
  var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)
       
      VStack {
        
        navigationTrallingButton()
        
        Spacer()
          .frame(height: 10)
        
        switchSelectDropDownView()
        
        Spacer()
      }
    }
    .overlay {
      dropDownView()
    }
    .onTapGesture {
      if store.isExpandedDropDown {
        withAnimation {
          store.isExpandedDropDown = false
        }
      }
    }
    
    .task {
//      store.send(.attandanceCheck(.async(.fetchMember)))
//      store.send(.async(.fetchCurrentUser))
    }
    
    .onAppear {
//      store.send(.attandanceCheck(.async(.fetchAttenDance)))
//      store.send(.view(.appearSelectPart(selectPart: .all)))
    }
//    
//    .onChange(of: store.attendanceCheckInModel) { oldValue, newValue in
//      store.send(.async(.fetchAttendanceDataResponse(.success(newValue))))
//    }
//    
    .gesture(
      DragGesture()
        .onEnded { value in
          if value.translation.width < -UIScreen.screenWidth * 0.02 {
            store.send(.attandanceCheck(.view(.swipeNext)))
            
            
          } else if value.translation.width > UIScreen.screenWidth * 0.02 {
            store.send(.attandanceCheck(.view(.swipePrevious)))
            
            
          }
        }
    )
  }
}

extension CoreMemberMainView {
  
  @ViewBuilder
  fileprivate func navigationTrallingButton() -> some View {
    VStack {
      Spacer()
        .frame(height: 10)
      
      HStack(spacing: .zero) {
        
        Button {
          withAnimation {
            store.isExpandedDropDown.toggle()
          }
        } label: {
          HStack {
            Text(store.selectDropDownItem.desc)
                  .pretendardCustomFont(textStyle: .title2NormalBold)
                  .foregroundColor(.staticWhite)
              
              Spacer()
                  .frame(width: 10)
              
            Image(systemName: store.isExpandedDropDown ? "chevron.up" : "chevron.down")
                  .foregroundColor(.white)
                  .frame(width: 12, height: 7)
                  .bold()
          }
          .padding(.leading, 24)
        }
        
        Spacer()
        
        Circle()
          .fill(.blue70)
          .frame(width: 36, height: 36)
          .overlay {
            Image(asset: store.qrcodeImage)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .foregroundStyle(.staticWhite)
          }
          .onTapGesture {
            store.send(.navigation(.presentQrcode))
          }
        
        Spacer()
          .frame(width: 12)
        
        Circle()
          .fill(.gray80)
          .frame(width: 36, height: 36)
          .overlay {
            Image(asset: .user)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .foregroundStyle(.staticWhite)
          }
      }
    }
    .padding(.trailing, 24)
  }
  
  @ViewBuilder
  fileprivate func switchSelectDropDownView() -> some View {
    switch store.selectDropDownItem {
    case .attandance:
      AttandanceCheckView(store: self.store.scope(state: \.attandanceCheck, action: \.attandanceCheck))
      
    case .schedule:
      EmptyView()
      
    }
  }
  
  @ViewBuilder
  fileprivate func dropDownView() -> some View {
    if store.isExpandedDropDown {
      ZStack {
        // 반투명 배경
        Rectangle()
          .fill(Color.black.opacity(0.8))
          .edgesIgnoringSafeArea(.all)
          .onTapGesture {
            // 배경 클릭 시 닫힘
            withAnimation {
              store.isExpandedDropDown = false
            }
          }
        
        // 드롭다운 리스트
        VStack {
          DropdownList(
            items: store.dropDownItem,
            selectedItem: $store.selectDropDownItem,
            isExpanded: $store.isExpandedDropDown
          )
          .frame(width: 140) // 드롭다운 리스트의 너비
          .padding(.leading, 24)
          .cornerRadius(6)
        }
        .offset(x: -UIScreen.screenWidth * 0.3 ,y: -UIScreen.screenHeight * 0.32 ) // 리스트의 위치 조정
      }
      .zIndex(1) // 드롭다운이 다른 뷰보다 위에 표시
    }
  }
  
}
