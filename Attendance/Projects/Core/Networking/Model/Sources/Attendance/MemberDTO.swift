//
//  MemberDTO.swift
//  DDDAttendance
//
//  Created by 서원지 on 9/23/24.
//


import Foundation

public struct MemberDTO: Codable, Equatable {
  public var memberId: String
  public var memberType: MemberType
  public var manging: Managing
  public var memberTeam: SelectTeam
  public var name: String
  public var roleType: SelectPart
  public var createdAt: Date
  public var updatedAt: Date
  public var status: AttendanceType?
  public var generation: Int
  
  public init(
    memberId: String,
    memberType: MemberType = .coreMember,
    manging: Managing = .notManging,
    memberTeam: SelectTeam = .notTeam,
    name: String,
    roleType: SelectPart = .all,
    createdAt: Date = Date(),
    updatedAt: Date = Date(),
    status: AttendanceType? = .notAttendance,
    generation: Int = 0
  ) {
    self.memberId = memberId
    self.memberType = memberType
    self.manging = manging
    self.memberTeam = memberTeam
    self.name = name
    self.roleType = roleType
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.status = status
    self.generation = generation
  }
}

extension MemberDTO {
  static func generateCustomMemberId() -> String {
    let uuidPart = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(22)
    return String(uuidPart)
  }
  
  static func mockMemberData() -> [MemberDTO] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // Parse the dates for the DTO
    guard let specificDate = dateFormatter.date(from: "2024-09-16") else {
      fatalError("Invalid date format")
    }
    
    guard let specificCreateDate = dateFormatter.date(from: "2024-09-15") else {
      fatalError("Invalid date format")
    }
    
    // Return mock DTO data
    return [
      MemberDTO(
        memberId: generateCustomMemberId(),
        memberType: .member,
        manging: .projectTeamManging,
        memberTeam: .ios1,
        name: "DDD iOS",
        roleType: .iOS,
        createdAt: specificCreateDate,
        updatedAt: specificDate,
        status: .present,
        generation: 11
      ),
      MemberDTO(
        memberId: generateCustomMemberId(),
        memberType: .member,
        manging: .snsManagement,
        memberTeam: .notTeam,
        name: "DDD Android",
        roleType: .android,
        createdAt: specificCreateDate,
        updatedAt: specificDate,
        status: .present,
        generation: 11
      )
    ]
  }
  
}
