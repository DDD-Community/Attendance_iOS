//
//  SelectMangerRoleDTO+.swift
//  Model
//
//  Created by Wonji Suh  on 1/1/26.
//

import Foundation
import Entity

public extension SelectMangerRoleDTOReponse {
  func toDomain() -> SelectManaging {
    return SelectManaging(
      managingKeys: self.description,
      managing: StaffManaging(rawValue: self.key) ?? .attendanceCheck
    )
  }
}

public extension Array where Element == SelectMangerRoleDTOReponse {
  func toDomain() -> [SelectManaging] {
    return self.map { $0.toDomain() }
  }
}

public extension SelectMangerRoleDTO {
  func toDomain() -> [SelectManaging] {
    return self.data.toDomain()
  }
}
