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
      Color.staticWhite
        .edgesIgnoringSafeArea(.all)

      VStack {
        scheduleHeader()

        Spacer()
          .frame(height: 20)

        if store.loading {
          Spacer()

          AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)

          Spacer()
        } else {
          VStack(spacing: 0) {
            ScrollView(.vertical) {
//              scheduleList()
            }
            .scrollIndicators(.hidden)

            Spacer()
              .frame(height: 16)

            confirmButton()
              .padding(.horizontal, 24)
              .padding(.bottom, 16)
          }
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
        .foregroundStyle(.borderInverse)
    }
  }

//  @ViewBuilder
//  private func scheduleList() -> some View {
//    let schedules = store.scheduleModel?.data ?? []
//
//    LazyVStack(spacing: 8) {
//      ForEach(schedules, id: \.id) { item in
//        scheduleCardRow(item: item)
//      }
//    }
//    .padding(.top, 8)
//    .padding(.bottom, 8)
//  }

//  @ViewBuilder
//  private func scheduleCardRow(
//    item: ScheduleResponseModel
//  ) -> some View {
//    let isSelected = store.selectedSchedule?.id == item.id
//
//    scheduleCard(item: item, isSelected: isSelected)
//      .onTapGesture {
//        handleScheduleSelection(item: item)
//      }
//  }

//  private func handleScheduleSelection(item: ScheduleResponseModel) {
//
//    store.send(.view(.selectSchedule(item: item)))
//  }


@ViewBuilder
  private func confirmButton() -> some View {
    CustomButton(
      action: {
        store.send(.view(.confirmSelection))
      },
      title: "확인",
      config: CustomButtonConfig.create(),
      isEnable: store.enableButton
    )
  }
}
