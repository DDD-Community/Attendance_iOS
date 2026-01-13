//
//  AttendanceStatusDTO+.swift
//  Model
//
//  Created by Wonji Suh  on 1/13/26.
//

import Entity

// MARK: - AttendanceStatusDTO Extensions

public extension AttendanceStatusDTOResponse {
  func toDomain() -> AttendanceStatus {
    return AttendanceStatus.from(apiKey: self.name) ?? .absent
  }
}

public extension Array where Element == AttendanceStatusDTOResponse {
  func toDomain() -> [AttendanceStatus] {
    return self.map { $0.toDomain() }
  }
}

public extension AttendanceStatusDTO {
  func toDomain() -> [AttendanceStatus] {
    return self.data.toDomain()
  }
}

