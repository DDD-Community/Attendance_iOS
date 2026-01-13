//
//  EditAttendanceDTO.swift
//  Model
//
//  Created by Wonji Suh  on 1/13/26.
//

import Foundation

public struct EditAttendanceDTO: Decodable {
  public let code: String?
  public let message: String?
  public let detail: String?

  public init(
    code: String? = nil,
    message: String? = nil,
    detail: String? = nil
  ) {
    self.code = code
    self.message = message
    self.detail = detail
  }
}
