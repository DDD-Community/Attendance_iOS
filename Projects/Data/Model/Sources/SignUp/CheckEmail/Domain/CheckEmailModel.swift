//
//  CheckEmailModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias CheckEmailModel = BaseResponseDTO<CheckEmailResponseModel>

public struct CheckEmailResponseModel: Decodable, Equatable {
  public let emailUsed: Bool?

  public init(
    emailUsed: Bool?
  ) {
    self.emailUsed = emailUsed
  }
}
