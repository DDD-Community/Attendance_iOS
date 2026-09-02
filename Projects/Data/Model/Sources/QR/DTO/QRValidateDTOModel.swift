//
//  QRValidateDTOModel.swift
//  Model
//
//  Created by DDD on 5/20/25.
//

import Foundation

public struct QRValidateDTO: Decodable, Sendable {
  public let code: String?
  public let message: String?
  public let detail: String?
  public let status: String? // ATTENDED || LATE || ABSENT

  public init(code: String? = nil, message: String? = nil, detail: String? = nil, status: String? = nil) {
    self.code = code
    self.message = message
    self.detail = detail
    self.status = status
  }
}
