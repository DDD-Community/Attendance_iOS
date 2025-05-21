//
//  MemberMainView.swift
//  Presentation
//
//  Created by 홍은표 on 1/2/25.
//

import SwiftUI

import DesignSystem
import Model

import ComposableArchitecture

struct MemberMainView: View {
  @Bindable private var store: StoreOf<MemberMain>

  init(store: StoreOf<MemberMain>) {
    self.store = store
  }

  var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      navigationBar

      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 56) {
          attendanceStatus

          generationScheduleListView
        }
        .padding(.horizontal, 24)
      }
    }
    .background(.backGroundPrimary)
    .customAlert(
      isPresented: store.isPresentAttendanceWarningAlert,
      title: "주의해주세요!",
      message: "2번 지각 시 노쇼비를 돌려받을 수 없습니다.",
      onConfirm: {
        store.send(.view(.didTapDismissAlertButton))
      }
    )
    .onAppear {
      store.send(.view(.onAppear))
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
          store.send(.navigation(.routeToQRCode))
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
      Text("\(store.state.member?.name ?? "")님의 출석 현황")
        .pretendardFont(family: .Bold, size: 28)
        .foregroundStyle(.textPrimary)

      VStack(alignment: .leading, spacing: 8) {
        Text("활동 기간: \(store.startDate) - \(store.endDate)")
          .pretendardFont(family: .Regular, size: 14)
          .foregroundStyle(.textSecondary)

        AttendanceCard(
          attendanceCount: store.presentCount,
          lateCount: store.lateCount,
          absentCount: store.absentCount,
          showWarning: store.showAttendanceWarningIcon,
          onTapAbsentButton: {
            store.send(.view(.didTapAbesentButton))
          }
        )
      }
    }
    .padding(.top, 20)
  }

  private var generationScheduleListView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("\(store.member?.cohort ?? "")기 일정표")
        .pretendardFont(family: .Medium, size: 24)
        .foregroundStyle(.textPrimary)

      if store.schedules.isEmpty {
        emptyScheduleView
      } else {
        scheduleList
      }
    }
  }

  private var emptyScheduleView: some View {
    LazyVStack(spacing: 16) {
      Image(asset: .stamp)
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)

      Text("아직 일정이 없어요.")
        .pretendardCustomFont(textStyle: .body1NormalMedium)
        .foregroundStyle(.textSecondary)
    }
    .padding(.vertical, 64)
  }

  private var scheduleList: some View {
    LazyVStack(alignment: .leading, spacing: 12) {
      ForEach(store.schedules) {
        ScheduleCell(
          month: $0.month,
          day: $0.day,
          title: $0.title,
          description: $0.description,
          style: $0.status.toScheduleCellStyle
        )
      }
    }
  }
}

private extension AttendanceStatus {
  var toScheduleCellStyle: ScheduleCellStyle {
    switch self {
    case .present:
      return .init(
        backgroundColor: .blue40,
        stampImage: Image(asset: .present_stamp),
        dashBorder: false,
        monthDayOpacity: 0.2,
        titleDescriptionOpacity: 0.4
      )

    case .late:
      return .init(
        backgroundColor: .statusCautionary,
        stampImage: Image(asset: .late_stamp),
        dashBorder: false,
        monthDayOpacity: 0.2,
        titleDescriptionOpacity: 0.4
      )

    case .absent:
      return .init(
        backgroundColor: .clear,
        stampImage: nil,
        dashBorder: true,
        monthDayOpacity: 0.2,
        titleDescriptionOpacity: 0.3
      )

    case .tbd, .exception:
      return .init(
        backgroundColor: .gray90,
        stampImage: nil,
        dashBorder: false,
        monthDayOpacity: 1.0,
        titleDescriptionOpacity: 1.0
      )
    }
  }
}
