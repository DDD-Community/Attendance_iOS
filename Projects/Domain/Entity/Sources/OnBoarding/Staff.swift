//
//  Staff.swift
//  Entity
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation

public enum Staff: String, CaseIterable , Equatable{
  case member
  case manger

  public var description: String {
    switch self {
      case .member:
        return "MEMBER"
      case .manger:
        return "MANAGER"
    }
  }
}
