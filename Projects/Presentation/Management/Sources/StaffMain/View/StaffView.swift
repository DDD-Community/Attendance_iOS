//
//  StaffView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import SwiftUI

import DesignSystem
import Model

import ComposableArchitecture
import SDWebImageSwiftUI

struct StaffView: View {
  @Bindable var store: StoreOf<Staff>
  @State var isExpanded: Bool = false
  
  init(store: StoreOf<Staff>) {
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
  
    .gesture(
      DragGesture()
        .onEnded { value in
          if value.translation.width < -UIScreen.screenWidth * 0.02 {
            store.send(.attendanceCheck(.view(.swipeNext)))
          } else if value.translation.width > UIScreen.screenWidth * 0.02 {
            store.send(.attendanceCheck(.view(.swipePrevious)))
          }
        }
    )
    .sheet(item: $store.scope(state: \.destination?.qrcode, action: \.destination.qrcode)) { qrCodeStore in
      QRScannerView(store: qrCodeStore) {
        store.send(.view(.closeModal))
//        store.send(.attendanceCheck(.async(.onAppear)))
      }
      .presentationDetents([.height(UIScreen.screenHeight * 0.85)])
      .presentationCornerRadius(20)
      .presentationDragIndicator(.hidden)
      
    }
  }
}

extension StaffView {
  
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
            store.send(.view(.presentQrcode))
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
          .onTapGesture {
            store.send(.navigation(.presentManagerProfile))
          }
      }
    }
    .padding(.trailing, 24)
  }
  
  @ViewBuilder
  fileprivate func switchSelectDropDownView() -> some View {
    switch store.selectDropDownItem {
    case .attandance:
      AttendanceCheckView(store: self.store.scope(state: \.attendanceCheck, action: \.attendanceCheck))

    case .schedule:
      ScheduleView(store: self.store.scope(state: \.schedule, action: \.schedule))
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

