//
//  ScheduleModalView.swift
//  Management
//
//  Created by Wonji Suh  on 12/27/25.
//

import SwiftUI
import ComposableArchitecture
import Shareds
import SDWebImageSwiftUI

public struct ScheduleModalView: View {
  @Bindable var store: StoreOf<ScheduleModal>

  public init(store: StoreOf<ScheduleModal>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)

      VStack {
        scheduleHeader()

        Spacer()
          .frame(height: 16)

        if store.loading {
          Spacer()

          AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)

          Spacer()
        } else {
          ScrollView(.vertical) {
            scheduleList()
          }
          .scrollIndicators(.hidden)
        }
      }
      .onAppear {
        store.send(.async(.fetchSchedule))
      }
    }
  }
}

extension ScheduleModalView {

  @ViewBuilder
  private func scheduleHeader() -> some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 32)

      Text("일정 선택")
        .pretendardCustomFont(textStyle: .title2NormalBold)
        .foregroundStyle(.staticWhite)
    }
  }

  @ViewBuilder
  private func scheduleList() -> some View {
    LazyVStack {
      ForEach(store.scheduleModel?.data ?? [], id: \.id) { item in
        scheduleCard(
          month: item.startTime,
          day: item.startTime,
          title: item.title,
          description: item.description
        )
        .onTapGesture {
          print("tap item \(item)")
        }
      }
    }
  }

  @ViewBuilder
  private func scheduleCard(
    month: String,
    day: String,
    title: String,
    description: String
  ) -> some View {
    HStack(spacing: 12) {
      VStack(spacing: 2) {
        Text(String.monthOnlyString(from: month) ?? "")
          .pretendardCustomFont(textStyle: .body2NormalMedium)
          .foregroundColor(.staticBlack)

        Text(String.dayOnlyString(from: day) ?? "")
          .pretendardCustomFont(textStyle: .title3NormalMedium)
          .foregroundColor(.staticBlack)
      }
      .frame(width: 54, height: 54)
      .background(.blue20)
      .cornerRadius(10)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .pretendardCustomFont(textStyle: .body1NormalBold)
          .foregroundStyle(.staticWhite)

        Text(description)
          .pretendardCustomFont(textStyle: .body3NormalRegular)
          .foregroundStyle(.textSecondary)
      }

      Spacer()

    }
    .padding()
    .background(.gray90)
    .cornerRadius(12)
    .padding(.horizontal, 24)
  }

@ViewBuilder
  private func confirmButton() -> some View {
    CustomButton(
      action: {

      },
      title: "다음",
      config: CustomButtonConfig.create(),
      isEnable: store.enableButton
    )
  }
}
