//
//  UserRepositoryError.swift
//  Model
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

public enum UserRepositoryError: Error {
    case logout
    case fetchMember
    case memberNotExist
    case saveMember
    case editMember
    case fetchAttendanceList
    case checkMemberAttendance
    case todayAttendanceDoesNotExist
    case editMemberAttendance
    case inviteCodeNotExist
    case invalidInviteCode
    case fetchInviteCodeList
    case createInviteCode
    case removeInviteCode
    case saveAttendance
}
