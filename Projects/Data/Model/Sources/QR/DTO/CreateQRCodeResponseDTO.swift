//
//  CreateQRCodeResponseDTO.swift
//  Model
//
//  Created by DDD on 5/18/25.
//

import Foundation

public struct CreateQRCodeResponseDTO: Decodable, Sendable {
  public let id: Int
  public let qrBase64: String
}