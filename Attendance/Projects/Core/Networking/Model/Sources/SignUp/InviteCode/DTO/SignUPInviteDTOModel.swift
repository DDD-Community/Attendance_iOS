//
//  SignUPInviteDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

public struct SignUPInviteDTOModel: Codable, Equatable {
  public let code: Int
  public let message: String
  public let data: SignUPInviteResponseDTOModel
  
  public init(
    code: Int,
    message: String,
    data: SignUPInviteResponseDTOModel
  ) {
    self.code = code
    self.message = message
    self.data = data
  }
  
}

public struct SignUPInviteResponseDTOModel: Codable, Equatable {
  public let valid: Bool
  public let inviteCodeID, inviteType: String
  public  let oneTimeUse: Bool
  public let errorMessage: String?
  
  public init(
    valid: Bool,
    inviteCodeID: String,
    inviteType: String,
    oneTimeUse: Bool,
    errorMessage: String? = nil
  ) {
    self.valid = valid
    self.inviteCodeID = inviteCodeID
    self.inviteType = inviteType
    self.oneTimeUse = oneTimeUse
    self.errorMessage = errorMessage
  }
}
