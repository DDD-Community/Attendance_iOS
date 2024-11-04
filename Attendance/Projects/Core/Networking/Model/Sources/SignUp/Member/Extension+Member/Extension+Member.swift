//
//  Extension+Member.swift
//  Model
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation

public extension Member {
  func toMembersModel() -> MemberDTOSignUp {
    return MemberDTOSignUp(
      uid: self.uid ,
      memberid: self.memberid ,
      email: self.email,
      name: self.name ,
      role: self.role ?? .all,
      memberType: self.memberType,
      memberTeam: self.memberTeam ?? .notTeam,
      isAdmin: self.isAdmin,
      generation: self.generation
    )
  }
  
  func toMemberDictionary() -> [String: Any]  {
    return [
        "uid": uid ,
        "memberid": memberid,
        "email": email,
        "name": name,
        "role": role?.rawValue ?? "",
        "memberType": memberType.rawValue,
        "memberTeam": memberTeam?.rawValue ?? "",
        "isAdmin": isAdmin ,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "generation": generation
    ]
  }
  
  func toCoreMembersModel() -> CoreMemberDTOSignUp {
    return CoreMemberDTOSignUp(
      uid: self.uid,
      memberid: self.memberid,
      email: self.email,
      name: self.name,
      role: self.role ?? .all,
      memberType: self.memberType,
      manging: self.manging ?? .notManging,
      isAdmin: self.isAdmin,
      generation: self.generation
    )
  }
  
  func toCoreMemberDictionary() -> [String: Any]  {
    return [
        "uid": uid ,
        "memberid": memberid,
        "email": email,
        "name": name,
        "role": role?.rawValue ?? "",
        "memberType": memberType.rawValue,
        "manging": manging?.rawValue ?? "",
        "isAdmin": isAdmin ,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "generation": generation
    ]
  }
  
  func toUserMember() -> UserDTOMember {
    return UserDTOMember(
      uid: self.uid,
      memberid: self.memberid,
      name: self.name,
      email: self.email,
      role: self.role ?? .all,
      memberType: self.memberType,
      manging: self.manging ?? .notManging,
      memberTeam: self.memberTeam ?? .notTeam,
      isAdmin: self.isAdmin,
      generation: self.generation
    )
  }
}
