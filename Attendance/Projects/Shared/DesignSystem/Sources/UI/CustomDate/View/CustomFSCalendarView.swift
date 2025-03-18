//
//  CustomFSCalendarView.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 2/8/25.
//

import SwiftUI

import FSCalendar

public struct CustomFSCalendarView: UIViewRepresentable {
  @Binding var selectDate: Date
  @Binding var currentMonth: Date
  
  public init(
    selectDate: Binding<Date>,
    currentMonth: Binding<Date>
  ) {
    self._selectDate = selectDate
    self._currentMonth = currentMonth
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
    
  // MARK: - ui 그리기
  public func makeUIView(context: Context) -> UIView {
      let containerView = UIView()
      
      // FSCalendar 인스턴스 생성 및 설정
      let calendar = FSCalendar()
      calendar.delegate = context.coordinator
      calendar.dataSource = context.coordinator
      context.coordinator.calendar = calendar
      calendar.scrollDirection = .horizontal
      calendar.scrollEnabled = true
      calendar.allowsMultipleSelection = false
      calendar.appearance.selectionColor = UIColor.blue
      
      // 외관 설정
      calendar.appearance.headerDateFormat = " "
      calendar.appearance.weekdayTextColor = .black
      calendar.appearance.headerTitleAlignment = .center
      calendar.appearance.borderRadius = 20
      calendar.appearance.todayColor = .white
      calendar.appearance.titleTodayColor = .black
      calendar.placeholderType = .none
      calendar.swipeToChooseGesture.isEnabled = false
      calendar.locale = Locale(identifier: "ko_KR")
      calendar.appearance.headerMinimumDissolvedAlpha = 0.0
      calendar.headerHeight = 20
      calendar.backgroundColor = .white
      
      calendar.layer.cornerRadius = 20
      calendar.layer.masksToBounds = true
      
      containerView.addSubview(calendar)
      calendar.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
          calendar.topAnchor.constraint(equalTo: containerView.topAnchor),
          calendar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
          calendar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
          calendar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
      ])
      
      // 오늘 날짜 선택하지 않고, 현재 페이지만 설정
      DispatchQueue.main.async {
          context.coordinator.calendar.setCurrentPage(selectDate, animated: true)
          context.coordinator.calendar.reloadData()
      }
      
      return containerView
  }
  
  public func updateUIView(_ uiView: UIView, context: Context) {
    if let calendar = context.coordinator.calendar {
      calendar.reloadData()
//      currentMonth = calendar.currentPage
      updateHeaderTitle(coordinator: context.coordinator)
    }
  }
  
  // 헤더 제목 업데이트 메서드
  public func updateHeaderTitle(coordinator: Coordinator) {
    guard let calendar = coordinator.calendar else { return }
    DispatchQueue.main.async {
      calendar.currentPage =  coordinator.parent.currentMonth
    }
  }
  
  public class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    let parent: CustomFSCalendarView
    var calendar: FSCalendar!
    
    public init(
      parent: CustomFSCalendarView
    ) {
      self.parent = parent
    }
   
    // MARK: - 날짜 선택시 호출 되는 함수
    public func calendar(
      _ calendar: FSCalendar,
      didSelect date: Date,
      at monthPosition: FSCalendarMonthPosition
    ) {
      if Calendar.current.isDate(date, inSameDayAs: parent.selectDate) {
        return
      }
      
      calendar.deselect(parent.selectDate)
      parent.selectDate = date
      
      DispatchQueue.main.async {
        calendar.select(date, scrollToDate: true)
        self.parent.selectDate = date
        calendar.reloadData()
      }
    }
    
    // MARK: - 오늘 날짜에 Dot
//    public func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
//      // 오늘 날짜에만 이벤트(dot)를 추가
//      if Calendar.current.isDateInToday(date) {
//        return 1
//      }
//      return 0
//    }
    
//    // 오늘 날짜의 dot 색상을 설정하는 메서드
//    public func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
//      if Calendar.current.isDateInToday(date) {
//        return [UIColor.blue]  // 오늘 날짜 dot 색상: 초록색
//      }
//      return nil
//    }
    
    
    // 선택된 날짜의 배경을 커스터마이징하는 메서드
    public func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
      if Calendar.current.isDate(date, inSameDayAs: parent.selectDate) {
            return UIColor.blue // 선택된 날짜의 배경을 파란색으로 처리
        }
        return nil // 그 외의 날짜는 기본색 유지
    }
    
    // 현재 페이지 변경 시 호출되는 메서드
    public func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
      calendar.currentPage = parent.currentMonth
    }
    
  }
}
