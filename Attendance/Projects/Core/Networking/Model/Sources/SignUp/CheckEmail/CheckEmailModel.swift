//
//  CheckEmailModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

// MARK: - Welcome
public struct CheckEmailModel: Decodable {
  let emailUsed: Bool?
  
  enum CodingKeys: String, CodingKey {
    case emailUsed = "email_used"
  }
}
