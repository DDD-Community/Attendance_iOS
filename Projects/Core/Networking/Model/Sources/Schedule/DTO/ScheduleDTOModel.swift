//
//  ScheduleDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation


public typealias ScheduleDTOModel = BaseResponseDTO<[ScheduleDTOResponseModel]>

// MARK: - Datum
public struct ScheduleDTOResponseModel: Codable, Equatable {
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
