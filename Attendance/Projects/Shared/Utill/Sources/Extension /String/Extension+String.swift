//
//  Extension+String.swift
//  Utill
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation

public extension String {
    static func makeQrCodeValue(userID: String, eventID: String, startTime: Date, endTime: Date) -> String {
        let startTimeString = startTime.formattedString()
        let setEndTime = endTime.addingTimeInterval(1800)
        let endTimeString = setEndTime.formattedString()
        return "\(userID)+\(eventID)+\(startTimeString)+\(endTimeString)"
    }
    
  static func stringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.date(from: dateString)
    }
    
  static func stringToTimeAndDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
        return dateFormatter.date(from: dateString)
    }
    
  static func stringToTimeFirebaseDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분 ss초 'UTC'Z"
        return dateFormatter.date(from: dateString)
    }

}
