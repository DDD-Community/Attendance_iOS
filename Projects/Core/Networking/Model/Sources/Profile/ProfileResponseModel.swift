//
//  ProfileModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public struct ProfileResponseModel: Hashable {
  public let id: String
  public let userID: Int
  public let name: String
  public let inviteCodeID: String
  public let role: SelectPart
  public let team: SelectTeam
  public let crew: SelectTeam
  public let responsibility: Managing
  public let cohort: String
  public let cohortID: String
  public let isStaff: Bool

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  public static func == (lhs: ProfileResponseModel, rhs: ProfileResponseModel)  -> Bool {
    return lhs.id == rhs.id
  }
}
