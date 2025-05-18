//
//  AttendanceCheckDTOModels.swift
//  Model
//
//  Created by Wonji Suh  on 5/15/25.
//

import Foundation


public typealias AttendanceCheckDTOModel = BaseResponse<AttendanceCheckDTOResponseModel>

public struct AttendanceCheckDTOResponseModel: Decodable {
    let id: String
    let profileSummary: ProfileSummaryDTO
    let scheduleSummary: ScheduleSummaryDTO
    let updatedAt, status: String?
    let method, note: String?

    enum CodingKeys: String, CodingKey {
        case id
        case profileSummary = "profile_summary"
        case scheduleSummary = "schedule_summary"
        case updatedAt = "updated_at"
        case status, method, note
    }
}

// MARK: - ProfileSummary
public struct ProfileSummaryDTO: Decodable {
    let name: String?
    let role, team, cohort, inviteCodeID: String?

    enum CodingKeys: String, CodingKey {
        case name, role, team, cohort
        case inviteCodeID = "invite_code_id"
    }
}

// MARK: - ScheduleSummary
public struct ScheduleSummaryDTO: Decodable {
    let id, title, description: String?
    let startTime, endTime: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case startTime = "start_time"
        case endTime = "end_time"
    }
}
