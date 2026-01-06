//
//  VerifyCodeEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation

public struct VerifyCodeEntity: Equatable {
  public let generationID: Int
  public let type: Staff

  public init(
    generationID: Int,
    type: Staff
  ) {
    self.generationID = generationID
    self.type = type
  }
}
