//
//  QRValidateDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public typealias QRValidateDTOModel = BaseResponse<QRValidateDTOResponseModel>

// MARK: - DataClass
public struct QRValidateDTOResponseModel: Decodable{
  let valid: Bool?
  let userID: Int?
  let username: String?
  
  enum CodingKeys: String, CodingKey {
    case valid
    case userID = "user_id"
    case username
  }
}
