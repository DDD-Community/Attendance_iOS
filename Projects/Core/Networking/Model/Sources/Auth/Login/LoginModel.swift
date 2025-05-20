//
//  LoginModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias LoginModel = BaseResponse<LoginResponseModel>

public struct LoginResponseModel: Decodable {
  let id: Int
  let email, refresh, access: String
  
}
