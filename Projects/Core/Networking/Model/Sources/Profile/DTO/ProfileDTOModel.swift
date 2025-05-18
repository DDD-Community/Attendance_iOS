//
//  ProfileResponseDTO.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

import Foundation

public typealias ProfileDTOModel = BaseResponseDTO<ProfileResponseDTO>

public struct ProfileResponseDTO: Decodable, Equatable {
  public let id, name, inviteCodeID, role: String
  public let team: SelectPart
  public let isStaff: Bool
  public let crew: SelectTeam?
  public let generation: String
  public let responsibility: Managing?
  
  public init(
    id: String,
    name: String,
    inviteCodeID: String,
    role: String,
    team: SelectPart,
    isStaff: Bool,
    generation: String,
    crew: SelectTeam? = nil,
    responsibility: Managing? = nil
  ) {
    self.id = id
    self.name = name
    self.inviteCodeID = inviteCodeID
    self.role = role
    self.team = team
    self.isStaff = isStaff
    self.generation = generation
    self.crew = crew
    self.responsibility = responsibility
  }
}


