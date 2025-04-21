//
//  MemberMainView.swift
//  Presentation
//
//  Created by 홍은표 on 1/2/25.
//

import SwiftUI

import DesignSystem

import ComposableArchitecture

struct MemberMainView: View {
  @Bindable private var store: StoreOf<MemberMain>
  
  init(store: StoreOf<MemberMain>) {
    self.store = store
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      navigationBar
      
      ScrollView {
        VStack(alignment: .leading, spacing: .zero) {
          attendanceStatus
        }
        .padding(.horizontal, 24)
      }
    }
    .customAlert(
      isPresented: store.isPresentAttendanceWarningAlert,
      title: "주의해주세요!",
      message: "2번 지각 시 노쇼비를 돌려받을 수 없습니다.",
      onConfirm: {
        store.send(.view(.didTapDismissAlertButton))
      }
    )
    .task {
      store.send(.async(.fetchCurrentUser))
    }
  }
  
  private var navigationBar: some View {
    HStack(spacing: .zero) {
      Image(asset: ImageAsset.appLogo)
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 25, height: 28)
        .foregroundStyle(.gray60)
      
      Spacer()
      
      HStack(spacing: 12) {
        Button(action: {
          store.send(.navigation(.presentQRCode))
        }) {
          Image(asset: ImageAsset.qrCode)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundStyle(.staticWhite)
        }
        .frame(width: 36, height: 36)
        .background(.blue70)
        .clipShape(.rect(cornerRadius: 99))
        .overlay(
          RoundedRectangle(cornerRadius: 99)
            .stroke(Color.blue30, lineWidth: 1)
        )
        
        Button(action: {
          store.send(.navigation(.routeToProfile))
        }) {
          Image(asset: ImageAsset.managementProfile)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundStyle(.staticWhite)
        }
        .frame(width: 36, height: 36)
        .background(.gray80)
        .clipShape(RoundedRectangle(cornerRadius: 99))
      }
    }
    .frame(height: 52)
    .padding(.horizontal, 24)
  }
  
  private var attendanceStatus: some View {
    VStack(alignment: .leading, spacing: 16) {
      if let member = store.state.member {
        Text("\(member.name)님의 출석 현황")
          .pretendardFont(family: .Bold, size: 28)
          .foregroundStyle(.textPrimary)
        
        VStack(alignment: .leading, spacing: 8) {
          // TODO: - 활동 기간 표시
          Text("활동 기간: 1970.01.01 ~ 1970.01.01")
            .pretendardFont(family: .Regular, size: 14)
            .foregroundStyle(.textSecondary)
          
          // TODO: - 출석 현황 표시
          AttendanceCard(
            attendanceCount: 8,
            lateCount: 1,
            absentCount: 2,
            showWarning: store.shouldShowAttendanceWarningIcon,
            onTapAbsentButton: {
              store.send(.view(.didTapAbesentButton))
            }
          )
        }
      }
    }
    .padding(.top, 20)
  }
}
