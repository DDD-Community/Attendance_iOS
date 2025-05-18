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
  public let role: String
  public let team: String
  public let cohort: String
  public let isStaff: Bool
  public let createdAt: String
  public let updatedAt: String

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  public static func == (lhs: ProfileResponseModel, rhs: ProfileResponseModel)  -> Bool {
    return lhs.id == rhs.id
  }
}
