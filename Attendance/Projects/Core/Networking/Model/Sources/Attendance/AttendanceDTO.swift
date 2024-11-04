//
//  AttendanceDTO.swift
//  DDDAttendance
//
//  Created by 서원지 on 9/23/24.
//

import Foundation
import SwiftUI

public struct AttendanceDTO: Codable, Equatable {
  public var id: String
  public var memberId: String
  public var memberType: MemberType
  public var name: String
  public var roleType: SelectPart
  public var eventId: String
  public var updatedAt: Date
  public var status: AttendanceType?
  public var generation: Int

  public init(
        id: String,
        memberId: String,
        memberType: MemberType,
        name: String,
        roleType: SelectPart,
        eventId: String,
        updatedAt: Date,
        status: AttendanceType? = nil,
        generation: Int
    ) {
        self.id = id
        self.memberId = memberId
        self.memberType = memberType
        self.name = name
        self.roleType = roleType
        self.eventId = eventId
        self.updatedAt = updatedAt
        self.status = status
        self.generation = generation
    }
}


extension AttendanceDTO {
    static func generateCustomMemberId() -> String {
        let uuidPart = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(22)
        return String(uuidPart)
    }
    
    static func mockAttendanceData() -> [AttendanceDTO] {
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
            AttendanceDTO(
                id: UUID().uuidString,
                memberId: generateCustomMemberId(),
                memberType: .member,
                name: "DDD iOS",
                roleType: .iOS,
                eventId: "",
                updatedAt: Date(), // Set to current date
                status: .late,
                generation: 11
            ),
            AttendanceDTO(
                id: UUID().uuidString,
                memberId: generateCustomMemberId(),
                memberType: .member,
                name: "DDD Android",
                roleType: .android,
                eventId: UUID().uuidString,
                updatedAt: specificDate, // Use the specific update date
                status: .present,
                generation: 11
            )
        ]
    }
}
