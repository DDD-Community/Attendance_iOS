//
//  SignUpUserRequestDTO.swift
//  Service
//
//  Created by Wonji Suh  on 1/1/26.
//

public struct SignUpUserRequestDTO: Encodable {
  public let name: String
  public let generationId: Int
  public let jobRole: String
  public let teamId: Int?
  public let managerRoles: [String: String]?
  public let provider: String
  public let token: String
  public let invitationCode: String

  public init(
    name: String,
    generationId: Int,
    jobRole: String,
    teamId: Int?,
    managerRoles: [String : String]?,
    provider: String,
    token: String,
    invitationCode: String
  ) {
    self.name = name
    self.generationId = generationId
    self.jobRole = jobRole
    self.teamId = teamId
    self.managerRoles = managerRoles
    self.provider = provider
    self.token = token
    self.invitationCode = invitationCode
  }
}
