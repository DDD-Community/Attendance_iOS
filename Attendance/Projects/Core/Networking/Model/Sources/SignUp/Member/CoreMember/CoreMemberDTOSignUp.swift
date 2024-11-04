//
//  CoreMemberDTOSignUp.swift
//  Model
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation

public struct CoreMemberDTOSignUp: Codable, Equatable {
  public var uid: String
  public var memberid: String
  public var name: String
  public var email: String
  public var role: SelectPart
  public var memberType: MemberType
  public var manging: Managing
  public var isAdmin: Bool
    /// 기수
  public var generation: Int
  
  public init(
    uid: String,
    memberid: String,
    email: String,
    name: String,
    role: SelectPart,
    memberType: MemberType,
    manging: Managing,
    isAdmin: Bool,
    generation: Int
  ) {
    self.uid = uid
    self.memberid = memberid
    self.email = email
    self.name = name
    self.role = role
    self.memberType = memberType
    self.manging = manging
    self.isAdmin = isAdmin
    self.generation = generation
  }
}

