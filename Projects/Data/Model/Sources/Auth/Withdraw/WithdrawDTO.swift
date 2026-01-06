//
//  WithdrawDTO.swift
//  Model
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation

public struct WithdrawDTO: Decodable {
  public let code: String?
  public let message: String?
  public let detail: String?

  public init(code: String? = nil, message: String? = nil, detail: String? = nil) {
    self.code = code
    self.message = message
    self.detail = detail
  }
}
