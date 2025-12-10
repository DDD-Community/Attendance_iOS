//
//  Task+.swift
//  Utill
//
//  Created by Wonji Suh  on 5/12/25.
//

import Foundation

public extension Task where Success == Never, Failure == Never {
  static func sleep(seconds: Double) async {
    let duration = UInt64(seconds * Double(NSEC_PER_SEC))
    try? await Task.sleep(nanoseconds: duration)
  }
}
