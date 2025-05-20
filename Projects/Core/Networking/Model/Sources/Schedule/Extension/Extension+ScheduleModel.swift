//
//  Extension+ScheduleModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension ScheduleDTOModel {
  func toDomain() -> ScheduleModel {
      let data = self.data?.compactMap { item in
      return ScheduleResponseModel(
        id: item.id ?? "",
        title: item.title ?? "",
        description: item.description ?? "",
        startTime: item.startTime ?? "",
        endTime: item.endTime ?? "",
      )
     }
    
    return ScheduleModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data ?? []
    )
  }
}
