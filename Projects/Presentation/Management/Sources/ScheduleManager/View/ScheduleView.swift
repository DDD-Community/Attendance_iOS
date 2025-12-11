//
//  ScheduleView.swift
//  Presentation
//
//  Created by Wonji Suh  on 5/9/25.
//

import SwiftUI

import Collections
import SwiftUIX
import DesignSystem
import ComposableArchitecture

struct ScheduleView: View {
  @Bindable var store: StoreOf<ScheduleManager>
  
  init(
    store: StoreOf<ScheduleManager>
  ) {
    self.store = store
  }
  
  var body: some View {
    LazyView {
      VStack {
        loadingScheduleView()
      }
    }
    .onAppear {
      store.send(.async(.fetchSchedule))
    }
  }
}


extension ScheduleView {
  
  @ViewBuilder
  fileprivate func loadingScheduleView() -> some View {
    if !store.loading {
      scheduleListView()
    } else {
      LoadingView()
    }
  }
  
  @ViewBuilder
  fileprivate func scheduleListView() -> some View {
    if let schedules = store.scheduleModel?.data {
      let grouped = schedules.grouped(by: { String.extractMonthString(from: $0.startTime) })
      
      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 16) {
          ForEach(Array(grouped.keys), id: \.self) { month in
            VStack(alignment: .leading, spacing: 16) {
              Text(month)
                .pretendardCustomFont(textStyle: .body1NormalBold)
                .foregroundStyle(.staticWhite)
                .padding(.horizontal, 28)
              
              
              let schedulesInMonth = grouped[month] ?? []

              ForEach(schedulesInMonth, id: \.scheduleId) { schedule in
                let day = String.extractDay(from: schedule.startTime)
                scheduleCard(
                  month: month,
                  day: "\(day)일",
                  title: schedule.title,
                  description: schedule.description
                )
                
              }
            }
          }
        }
        .padding(.top)
      }
      .scrollIndicators(.hidden)
      .scrollBounceBehavior(.basedOnSize)
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
        Text(month)
          .pretendardCustomFont(textStyle: .body2NormalMedium)
          .foregroundColor(.staticBlack)
        
        Text(day)
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
  
}

extension Collection {
    func grouped<Key: Hashable>(
        by keySelector: (Element) -> Key
    ) -> OrderedDictionary<Key, [Element]> {
        OrderedDictionary(grouping: self, by: keySelector)
    }
}
