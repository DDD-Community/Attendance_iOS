//
//  CheckEmailDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation


public typealias CheckEmailDTOModel = BaseResponse<CheckEmailDTOResponseModel>

// MARK: - Welcome
public struct CheckEmailDTOResponseModel: Decodable {
  let emailUsed: Bool?
  
  enum CodingKeys: String, CodingKey {
    case emailUsed = "email_used"
  }
}
