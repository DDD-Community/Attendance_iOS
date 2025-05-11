//
//  CalendarEventDataProvider.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 3/22/25.
//

import EventKit
import LogMacro
import Combine

public class CalendarEventDataProvider {
  private let eventStore = EKEventStore()
  private var holidays: Set<Date> = []
  
  public init() {
    // 비동기 작업을 Task로 실행하여 캘린더 접근 요청 및 공휴일 데이터를 가져옵니다.
    Task {
      await requestAccessToCalendar()
    }
  }
  
  private func requestAccessToCalendar() async {
    if #available(iOS 17.0, *) {
      // iOS 17 이상: 새로운 메서드 사용
      let (granted, error) = await withCheckedContinuation { continuation in
        eventStore.requestFullAccessToEvents { granted, error in
          continuation.resume(returning: (granted, error))
        }
      }
      guard granted, error == nil else { return }
      await fetchHolidays()
    } else {
      // iOS 16 이하: 기존 메서드 사용
      let (granted, error) = await withCheckedContinuation { continuation in
        eventStore.requestAccess(to: .event) { granted, error in
          continuation.resume(returning: (granted, error))
        }
      }
      guard granted, error == nil else { return }
      await fetchHolidays()
    }
  }
  
  private func fetchHolidays() async {
    let calendars = eventStore.calendars(for: .event)
    // "공휴일" 또는 "Holidays"라는 이름을 포함한 캘린더 필터링
    let holidayCalendars = calendars.filter { $0.title.contains("공휴일") || $0.title.contains("Holidays") }
    
    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    let oneYearAfter = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    
    for calendar in holidayCalendars {
      let predicate = eventStore.predicateForEvents(withStart: oneYearAgo, end: oneYearAfter, calendars: [calendar])
      let events = eventStore.events(matching: predicate)
      
      for event in events {
        let eventDate = Calendar.current.startOfDay(for: event.startDate)
        holidays.insert(eventDate)
      }
    }
  }
  
  public func isHoliday(date: Date) -> Bool {
    let normalizedDate = Calendar.current.startOfDay(for: date)
    return holidays.contains(normalizedDate)
  }
}


//public class CalendarEventDataProvider {
//  private let eventStore = EKEventStore()
//  private var holidays: Set<Date> = []
//  
//  public init() {
//    requestAccessToCalendar()
//  }
//  
//  private func requestAccessToCalendar() {
//    // iOS 17 이상: 새로운 메서드 사용
//    if #available(iOS 17.0, *) {
//      eventStore.requestFullAccessToEvents { [weak self] granted, error in
//        guard granted, error == nil else { return }
//        self?.fetchHolidays()
//      }
//    } else {
//      // iOS 16 이하: 기존 메서드 사용
//      eventStore.requestAccess(to: .event) { [weak self] granted, error in
//        guard granted, error == nil else { return }
//        self?.fetchHolidays()
//      }
//    }
//  }
//  
//  private func fetchHolidays() {
//    let calendars = eventStore.calendars(for: .event)
//    
//    // 공휴일 관련 캘린더 필터링 (예: 이름에 "공휴일" 포함)
//    let holidayCalendars = calendars.filter { $0.title.contains("공휴일") || $0.title.contains("Holidays") }
//    
//    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
//    let oneYearAfter = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
//    
//    for calendar in holidayCalendars {
//      let predicate = eventStore.predicateForEvents(withStart: oneYearAgo, end: oneYearAfter, calendars: [calendar])
//      let events = eventStore.events(matching: predicate)
//      
//      for event in events {
//        let eventDate = Calendar.current.startOfDay(for: event.startDate)
//        holidays.insert(eventDate)
//      }
//    }
//  }
//  
//  public func isHoliday(date: Date) -> Bool {
//    let normalizedDate = Calendar.current.startOfDay(for: date)
//    return holidays.contains(normalizedDate)
//  }
//}
