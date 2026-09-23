//
//  String+.swift
//  Utill
//
//  Created by DDD on 11/4/24.
//

import Foundation

public extension String {
  static func makeQrCodeValue(
    userID: String,
    eventID: String,
    startTime: Date,
    endTime: Date
  ) -> String {
    let startTimeString = startTime.formatted(.dateTime)
    let setEndTime = endTime.addingTimeInterval(1800)
    let endTimeString = setEndTime.formatted(.dateTime)
    return "\(userID)+\(eventID)+\(startTimeString)+\(endTimeString)"
  }
}
