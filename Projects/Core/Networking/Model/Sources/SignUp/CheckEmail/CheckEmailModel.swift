//
//  CheckEmailModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation


public typealias CheckEmailModel = BaseResponse<CheckEmailResponseModel>

// MARK: - Welcome
public struct CheckEmailResponseModel: Decodable {
  let emailUsed: Bool?
  
  enum CodingKeys: String, CodingKey {
    case emailUsed = "email_used"
  }
}
