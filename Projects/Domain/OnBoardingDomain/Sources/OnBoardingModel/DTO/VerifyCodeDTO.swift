//
//  VerifyCodeDTO.swift
//  OnBoardingDomain
//
//  Created by DDD on 12/30/25.
//

import Foundation

public struct VerifyCodeDTO: Decodable, Sendable {
  let generationID: Int
  let generationName, type, description: String

  enum CodingKeys: String, CodingKey {
    case generationID = "generationId"
    case generationName, type, description
  }
}
