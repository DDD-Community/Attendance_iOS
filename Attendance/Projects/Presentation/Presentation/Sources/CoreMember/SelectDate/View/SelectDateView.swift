//
//  SelectDateView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/31/25.
//

import SwiftUI
import ComposableArchitecture
import Shareds

struct SelectDateView: View {
  @Bindable var store: StoreOf<SelectDate>
  var selectAction:() -> Void = {}
  
  
  var body: some View {
    ZStack {
      Color.staticWhite
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        selectDateTitle()
        
        datePickerView()
        
        Spacer()
      }
    }
  }
}

extension SelectDateView {
  
  @ViewBuilder
  fileprivate func selectDateTitle() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 32)
      
      Text("날짜 선택")
        .pretendardCustomFont(textStyle: .title2NormalBold)
        .foregroundStyle(.gray90)
    }
  }
  
  @ViewBuilder
  fileprivate func datePickerView() -> some View {
    VStack {
      CustomCalendarView(selectedDate: $store.selectDate)
      //      DatePicker(selection: $store.selectDate, displayedComponents: [.date]) { }
      //        .environment(\.locale, Locale(identifier: "ko_KR"))
      //        .foregroundStyle(.black)
      //        .datePickerStyle(.graphical) // .automatic 대신 .compact 사용
      //        .labelsHidden()
      //        .background(.gray)
      //        .cornerRadius(10) // 둥근 모서리 적용
      //        .shadow(radius: 3) // 그림자 추가
    }
    .padding(.horizontal, 24)
  }
}


import SwiftUI

struct CalendarDate: Identifiable {
  let id = UUID()
  let date: Date
  let isCurrentMonth: Bool
}

extension Date {
  func startOfMonth() -> Date {
    let calendar = Calendar.current
    return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
  }
  
  func endOfMonth() -> Date {
    let calendar = Calendar.current
    return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
  }
  
  func daysInMonth() -> [CalendarDate] {
    let calendar = Calendar.current
    let startOfMonth = self.startOfMonth()
    let endOfMonth = self.endOfMonth()
    
    var days: [CalendarDate] = []
    let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1 // 0부터 시작
    
    // 이전 달의 빈칸 추가 (월 시작 요일 정렬)
    for _ in 0..<firstWeekday {
      days.append(CalendarDate(date: Date(), isCurrentMonth: false))
    }
    
    // 이번 달의 날짜 추가
    var currentDate = startOfMonth
    while currentDate <= endOfMonth {
      days.append(CalendarDate(date: currentDate, isCurrentMonth: true))
      currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
    }
    
    return days
  }
}

import SwiftUI

struct CustomCalendarView: View {
  @Binding private var selectedDate: Date?
  @State private var currentMonth: Date = Date()
  
  private let columns = Array(repeating: GridItem(.flexible()), count: 7) // 7열 (일~토)
  
  init(selectedDate: Binding<Date?>) {
    self._selectedDate = selectedDate
  }
  
  
  var body: some View {
    VStack {
      // 🔹 월 변경 버튼 및 현재 월 표시
      HStack {
        Button(action: { changeMonth(by: -1) }) {
          Image(systemName: "chevron.left")
            .padding()
            .foregroundColor(.black)
        }
        Spacer()
        Text(currentMonth, formatter: monthFormatter)
          .font(.title2)
          .foregroundStyle(.basicBlack)
          .bold()
        Spacer()
        Button(action: { changeMonth(by: 1) }) {
          Image(systemName: "chevron.right")
            .padding()
            .foregroundColor(.black)
        }
      }
      
      // 🔹 요일 헤더
      HStack {
        ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
          Text(day)
            .frame(maxWidth: .infinity)
            .foregroundColor((day == "일" || day == "토") ? .gray40 : .staticBlack)
            .bold()
        }
      }
      
      // 🔹 날짜 그리드 (LazyVGrid)
      LazyVGrid(columns: columns, spacing: 10) {
        ForEach(currentMonth.daysInMonth()) { day in
          ZStack {
            if day.isCurrentMonth {
              if isSelected(day.date) {
                Circle()
                  .fill(.statusFocus)
                  .frame(width: 40, height: 40)
              }
              
              Text("\(Calendar.current.component(.day, from: day.date))")
                .foregroundColor(isSelected(day.date) ? .staticWhite : .basicBlack)
                .padding(10)
            }
          }
          .frame(height: 40)
          .onTapGesture {
            selectedDate = day.date
          }
        }
      }
      .padding(.horizontal, 10)
      
    }
    .padding(.top, 10)
  }
  
  // ✅ 선택된 날짜 확인
  private func isSelected(_ date: Date) -> Bool {
    return selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!)
  }
  
  // ✅ 월 변경 기능
  private func changeMonth(by value: Int) {
    if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
      currentMonth = newMonth
    }
  }
  
  // ✅ 월 표시 Formatter
  private var monthFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 MM월"
    return formatter
  }
}
