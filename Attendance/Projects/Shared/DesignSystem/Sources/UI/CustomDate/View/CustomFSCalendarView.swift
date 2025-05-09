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
  @Binding var isDateSelected: Bool
  
  public init(
    selectDate: Binding<Date>,
    currentMonth: Binding<Date>,
    isDateSelected: Binding<Bool>
  ) {
    self._selectDate = selectDate
    self._currentMonth = currentMonth
    self._isDateSelected = isDateSelected
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  public func makeUIView(context: Context) -> UIView {
    let containerView = UIView()
    
    let calendar = FSCalendar()
    calendar.delegate = context.coordinator
    calendar.dataSource = context.coordinator
    context.coordinator.calendar = calendar
    
    // FSCalendar 페이징 설정
    calendar.scrollDirection = .horizontal
    calendar.scrollEnabled = true
    calendar.pagingEnabled = true
    calendar.placeholderType = .none
    calendar.scope = .month
    
    // (선택) 감속 속도 빠르게
    calendar.collectionView?.decelerationRate = .fast
    
    // 외관 설정
    calendar.appearance.selectionColor = .primaryBlue
    calendar.appearance.titleSelectionColor = .white
    calendar.appearance.headerDateFormat = " "
    calendar.appearance.weekdayTextColor = .black
    calendar.appearance.headerTitleAlignment = .center
    calendar.appearance.borderRadius = 20
    calendar.appearance.todayColor = .white
    calendar.appearance.titleTodayColor = .black
    calendar.appearance.headerMinimumDissolvedAlpha = 0.0
    calendar.headerHeight = 20
    calendar.backgroundColor = .white
    calendar.layer.cornerRadius = 20
    calendar.layer.masksToBounds = true
    
    containerView.addSubview(calendar)
    calendar.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      calendar.topAnchor.constraint(equalTo: containerView.topAnchor),
      calendar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
      calendar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
      calendar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])
    
    // 초기 페이지 설정 (자동 선택 제거)
    DispatchQueue.main.async {
      calendar.setCurrentPage(self.selectDate, animated: true)
      calendar.reloadData()
    }
    
    return containerView
  }
  
  public func updateUIView(_ uiView: UIView, context: Context) {
    if let calendar = context.coordinator.calendar {
      calendar.reloadData()
      updateHeaderTitle(coordinator: context.coordinator)
    }
  }
  
  public func updateHeaderTitle(coordinator: Coordinator) {
    guard let calendar = coordinator.calendar else { return }
    DispatchQueue.main.async {
      calendar.currentPage = coordinator.parent.currentMonth
    }
  }
  
  public class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    let parent: CustomFSCalendarView
    weak var calendar: FSCalendar!
    var calendarDataProvider = CalendarEventDataProvider()
    
    public init(parent: CustomFSCalendarView) {
      self.parent = parent
    }
    
    // MARK: - 날짜 선택
    public func calendar(
      _ calendar: FSCalendar,
      didSelect date: Date,
      at monthPosition: FSCalendarMonthPosition
    ) {
      if Calendar.current.isDate(date, inSameDayAs: parent.selectDate) {
        calendar.deselect(date)
        parent.selectDate = Date.now
        parent.isDateSelected = false
        calendar.reloadData()
        return
      }
      
      calendar.deselect(parent.selectDate)
      parent.selectDate = date
      parent.isDateSelected = true
      
      DispatchQueue.main.async {
        calendar.select(date, scrollToDate: true)
        calendar.reloadData()
      }
    }
    
    // MARK: - 날짜 배경 색상
    public func calendar(
      _ calendar: FSCalendar,
      appearance: FSCalendarAppearance,
      fillDefaultColorFor date: Date
    ) -> UIColor? {
      if Calendar.current.isDate(date, inSameDayAs: parent.selectDate),
         !Calendar.current.isDateInToday(date) {
        return .primaryBlue
      }
      return nil
    }
    
    // MARK: - 날짜 텍스트 색상
    public func calendar(
      _ calendar: FSCalendar,
      appearance: FSCalendarAppearance,
      titleDefaultColorFor date: Date
    ) -> UIColor? {
      let cal = Calendar.current
      let weekday = cal.component(.weekday, from: date)
      if date == parent.selectDate {
        return .white
      } else if calendarDataProvider.isHoliday(date: date) {
        return .red
      } else if weekday == 1 || weekday == 7 {
        return .gray
      }
      return .black
    }
    
    // MARK: - 페이지 변경
    public func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
      parent.currentMonth = calendar.currentPage
      
    }
  }
}
