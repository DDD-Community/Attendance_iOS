//
//  Member.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Model
import Foundation

public struct Member: Codable, Hashable, Equatable {
    /// Firebase Auth의 uid
    var uid: String
    var memberid: String
    var name: String
    var role: SelectPart
    var memberType: MemberType
    var manging: Managing?
    var memberTeam: ManagingTeam?
    var snsURL: String
    var createdAt: Date
    var updatedAt: Date
    var isAdmin: Bool
    
    /// 기수
    var generation: Int
  
  init(
    uid: String = "",
    memberid: String = "",
    name: String = "",
    role: SelectPart = .all,
    memberType: MemberType = .notYet,
    manging: Managing? = nil,
    memberTeam: ManagingTeam? = nil,
    snsURL: String? = nil,
    createdAt: Date = .now,
    updatedAt: Date = .now,
    isAdmin: Bool = false,
    generation: Int = 12
  ) {
    self.uid = uid
    self.memberid = memberid
    self.name = name
    self.role = role
    self.memberType = memberType
    self.manging = manging
    self.memberTeam = memberTeam
    self.snsURL = snsURL ?? ""
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.isAdmin = isAdmin
    self.generation = generation
  }
}
