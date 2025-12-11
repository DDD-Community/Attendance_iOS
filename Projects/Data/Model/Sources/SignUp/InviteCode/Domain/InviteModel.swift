//
//  InviteModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation
 
public typealias InviteCodeModel = BaseResponseDTO<InviteCodeResponseModel>

public struct InviteCodeResponseModel: Decodable, Equatable {
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
