//
//  InviteDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

public struct InviteDTOModel: Codable, Equatable {
  public let code: String
  public let expireData:Date
  public let isAdmin: Bool
  
  public init(
    code: String,
    expireData: Date,
    isAdmin: Bool
  ) {
    self.code = code
    self.expireData = expireData
    self.isAdmin = isAdmin
  }
}
