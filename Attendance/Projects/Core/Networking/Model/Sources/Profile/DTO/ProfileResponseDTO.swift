//
//  ProfileResponseDTO.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

import Foundation

public typealias ProfiledDTO = BaseResponseDTO<ProfileResponseDTO>

public struct ProfileResponseDTO: Codable, Equatable {
  public let id, name, inviteCodeID, role: String
  public let team: SelectPart
  public let isStaff: Bool
  
  public init(
    id: String,
    name: String,
    inviteCodeID: String,
    role: String,
    team: SelectPart,
    isStaff: Bool
  ) {
    self.id = id
    self.name = name
    self.inviteCodeID = inviteCodeID
    self.role = role
    self.team = team
    self.isStaff = isStaff
  }
}


