//
//  QRValidateDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public struct QRValidateDTO: Decodable {
  public let code: String?
  public let message: String?
  public let detail: String?

  public init(code: String? = nil, message: String? = nil, detail: String? = nil) {
    self.code = code
    self.message = message
    self.detail = detail
  }
}
