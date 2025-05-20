//
//  QRValidate.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public typealias QRValidateModel = BaseResponseDTO<QRValidateResponseModel>

// MARK: - DataClass
public struct QRValidateResponseModel: Decodable, Equatable {
  public let valid: Bool
  public let userID: Int
  public let username: String
  
  public init(
    valid: Bool,
    userID: Int,
    username: String
  ) {
    self.valid = valid
    self.userID = userID
    self.username = username
  }
}
