//
//  CreateQRCodeResponseDTO.swift
//  Model
//
//  Created by eunpyo on 5/18/25.
//

import Foundation

public struct CreateQRCodeResponseDTO: Decodable {
  public let id: Int
  public let qrBase64: String
}