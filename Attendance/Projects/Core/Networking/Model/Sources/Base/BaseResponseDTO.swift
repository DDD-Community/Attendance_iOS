//
//  BaseResponseDTO.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public struct BaseResponseDTO<DataDTO: Codable>: Codable {
  public let code: Int
  public let message: String
  public let data: DataDTO

  public init(
    code: Int,
    message: String,
    data: DataDTO
  ) {
    self.code    = code
    self.message = message
    self.data    = data
  }
}

extension BaseResponseDTO: Equatable where DataDTO: Equatable {}

