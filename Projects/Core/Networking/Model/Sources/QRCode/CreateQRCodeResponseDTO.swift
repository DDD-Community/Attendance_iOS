//
//  CreateQRCodeResponseDTO.swift
//  Model
//
//  Created by eunpyo on 5/18/25.
//

import Foundation

public struct CreateQRCodeResponseDTO: Decodable {
  public let qrString: String

  enum CodingKeys: String, CodingKey {
    case qrString = "qr_string"
  }
}
