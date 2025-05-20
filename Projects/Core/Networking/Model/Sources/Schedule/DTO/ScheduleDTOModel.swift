//
//  ScheduleDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation


public typealias ScheduleDTOModel = BaseResponse<[ScheduleDTOResponseModel]>

public struct ScheduleDTOResponseModel: Decodable {
  let id, title, description: String?
  let startTime, endTime: String?
  let createdAt: String?
  
  enum CodingKeys: String, CodingKey {
    case id, title, description
    case startTime = "start_time"
    case endTime = "end_time"
    case createdAt = "created_at"
  }
}
