//
//  SelectDropDownItem.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/16/25.
//

import Foundation

public enum SelectDropDownItem: String, CaseIterable {
  case attandance
  case schedule
  
  public var desc: String {
    switch self {
    case .attandance:
      return "출석"
    case .schedule:
      return "일정"
    }
  }
  
  static var item: [String] {
    SelectDropDownItem.allCases.map { $0.desc }
  }
}
