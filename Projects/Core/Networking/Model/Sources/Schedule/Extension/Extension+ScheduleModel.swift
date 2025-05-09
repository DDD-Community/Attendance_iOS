//
//  Extension+ScheduleModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension ScheduleModel {
  func toScheduleDTOModel() -> ScheduleDTOModel {
      let data = self.data?.compactMap { item in
      return ScheduleDTOResponseModel(
        id: item.id ?? "",
        title: item.title ?? "",
        description: item.description ?? "",
        startTime: item.startTime ?? "",
        endTime: item.endTime ?? "",
      )
     }
    
    return ScheduleDTOModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data ?? []
    )
  }
}
