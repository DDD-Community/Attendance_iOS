//
//  ScheduleModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias ScheduleModel = BaseResponseDTO<[ScheduleResponseModel]>

// MARK: - Datum
public struct ScheduleResponseModel: Decodable, Equatable {
    public let id, title, description: String
    public let startTime, endTime: String
  
   public init(
    id: String,
    title: String,
    description: String,
    startTime: String,
    endTime: String
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.startTime = startTime
    self.endTime = endTime
  }
    
}
