//
//  FeedbackResultOptionDTO.swift
//  Model
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct FeedbackResultOptionDTO: Decodable {
  public let optionId: String?
  public let label: String?
  public let count: Int?
}
