//
//  InviteModel.swift
//  Model
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation


public struct InviteModel: Decodable {
    let code: String?
    let expiredDate: Date?
    let isAdmin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case code
        case expiredDate = "expired_date"
        case isAdmin = "is_admin"
    }
  
  public init(code: String?, expiredDate: Date?, isAdmin: Bool?) {
    self.code = code
    self.expiredDate = expiredDate
    self.isAdmin = isAdmin
  }
}
