//
//  FireBaseCollection.swift
//  Model
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

public enum FireBaseCollection: String, CaseIterable {
  case member
  case event
  case attendance
  case inviteCode
  
  public var desc: String {
    switch self {
    case .member:
      return "members"
    case .event:
      return "events"
    case .attendance:
      return "attendance"
    case .inviteCode:
      return "invite_code"
    }
  }
}
