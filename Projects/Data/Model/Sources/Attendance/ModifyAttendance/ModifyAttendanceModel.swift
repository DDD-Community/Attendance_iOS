//
//  ModifyAttendanceModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public typealias ModifyAttendanceModel = BaseResponseDTO<ModifyAttendanceResponseModel>

// MARK: - DataClass
public struct ModifyAttendanceResponseModel: Decodable, Equatable {
  public let id: String
  public let profileSummary: ProfileSummary
  public let scheduleSummary: ScheduleSummary
  public let method, note: String
  public let status: AttendanceType
  
}
