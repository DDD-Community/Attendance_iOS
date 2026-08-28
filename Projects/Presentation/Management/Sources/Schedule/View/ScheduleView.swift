//
//  ScheduleView.swift
//  Presentation
//
//  Created by Wonji Suh  on 5/9/25.
//

import SwiftUI

import SwiftUIX
import DDDDesignKit
import ComposableArchitecture

@ViewAction(for: ScheduleReducer.self)
struct ScheduleView: View {
  @Bindable var store: StoreOf<ScheduleReducer>

  init(
    store: StoreOf<ScheduleReducer>
  ) {
    self.store = store
  }

  var body: some View {
    if store.loading {
      ScheduleSkeletonView()
    } else {
      VStack(spacing: 0) {
        // 메인 콘텐츠
        VStack(alignment: .leading, spacing: 0) {
          // 타이틀
          HStack {
            Text("\(store.userSession.generation) 일정표")
              .pretendardCustomFont(textStyle: .title2NormalBold)
              .foregroundStyle(.staticWhite)

            Spacer()
          }
          .padding(.horizontal, 20)
          .padding(.top, 24)
          .padding(.bottom, 20)

          // 스케줄 리스트
          scheduleListView()
        }
        .onAppear {
          send(.onAppear)
        }
      }
    }
  }
}

extension ScheduleView {

  @ViewBuilder
  fileprivate func scheduleListView() -> some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: 16) {
        ForEach(store.scheduleModel, id: \.id) { item in
          ScheduleCardView(
            month:"\(item.month)",
            day: "\(item.day)",
            title: item.name,
            description: item.description
          )
        }
      }
      .padding(.horizontal, 20)
    }
    .scrollIndicators(.hidden)
  }

}
