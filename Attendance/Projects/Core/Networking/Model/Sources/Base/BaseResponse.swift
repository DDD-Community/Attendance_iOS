//
//  BaseResponse.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation


/// 1) 공용 응답 래퍼
 public struct BaseResponse<T: Decodable>: Decodable {
  let code: Int?
  let message: String?
  let data: T?
}
