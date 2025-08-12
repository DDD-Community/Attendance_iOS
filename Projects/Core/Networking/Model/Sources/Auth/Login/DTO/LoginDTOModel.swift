//
//  LoginDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias LoginDTOModel = BaseResponse<LoginResponseDTOModel>

public struct LoginResponseDTOModel: Decodable {
  let id: Int
  let email, refresh, access: String
  
}
