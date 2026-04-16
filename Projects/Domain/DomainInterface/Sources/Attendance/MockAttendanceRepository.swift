//
//  MockAttendanceRepository.swift
//  DomainInterface
//
//  Created by TDD Automation on 2026-04-16
//

import Foundation
import Entity

public actor MockAttendanceRepository: AttendanceInterface {
    // MARK: - Configuration
    public enum Configuration {
        case adminCountSuccess
        case teamsSuccess
        case sessionAttendanceSuccess
        case statusSuccess
        case editSuccess
        case permissionDenied
        case invalidData
        case statisticsSuccess
        case teamFiltering
        case statusChangeFlow
        case consistencyValidation
        case permissionValidation
        case historyTracking
        case networkError
    }

    // MARK: - State
    private var configuration: Configuration = .adminCountSuccess
    private var adminCountCallCount = 0
    private var teamsCallCount = 0
    private var sessionAttendanceCallCount = 0
    private var editCallCount = 0
    private var lastSessionAttendanceParams: (scheduleId: Int, teamId: Int)?

    // MARK: - Public Configuration Methods
    public init(configuration: Configuration = .adminCountSuccess) {
        self.configuration = configuration
    }

    public static func adminCountSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .adminCountSuccess)
    }

    public static func teamsSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .teamsSuccess)
    }

    public static func sessionAttendanceSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .sessionAttendanceSuccess)
    }

    public static func statusSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .statusSuccess)
    }

    public static func editSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .editSuccess)
    }

    public static func permissionDenied() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .permissionDenied)
    }

    public static func invalidData() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .invalidData)
    }

    public static func statisticsSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .statisticsSuccess)
    }

    public static func teamFiltering() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .teamFiltering)
    }

    public static func statusChangeFlow() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .statusChangeFlow)
    }

    public static func consistencyValidation() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .consistencyValidation)
    }

    public static func permissionValidation() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .permissionValidation)
    }

    public static func historyTracking() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .historyTracking)
    }

    // MARK: - Call Count Getters
    public func getAdminCountCallCount() -> Int { adminCountCallCount }
    public func getTeamsCallCount() -> Int { teamsCallCount }
    public func getSessionAttendanceCallCount() -> Int { sessionAttendanceCallCount }
    public func getEditCallCount() -> Int { editCallCount }
    public func getLastSessionAttendanceParams() -> (scheduleId: Int, teamId: Int)? { lastSessionAttendanceParams }

    // MARK: - AttendanceInterface Implementation

    public func fetchAdminAttendanceCount() async throws -> AdminAttendanceCount {
        adminCountCallCount += 1

        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .adminCountSuccess:
            return AdminAttendanceCount(
                totalSchedules: 10,
                totalAttendees: 50,
                presentCount: 40,
                lateCount: 7,
                absentCount: 3
            )
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            return AdminAttendanceCount(totalSchedules: 0, totalAttendees: 0, presentCount: 0, lateCount: 0, absentCount: 0)
        }
    }

    public func fetchAttendanceTeams() async throws -> [AttendanceTeam] {
        teamsCallCount += 1

        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .teamsSuccess:
            return [
                AttendanceTeam(id: 1, name: "iOS Team", canManage: true),
                AttendanceTeam(id: 2, name: "Android Team", canManage: true),
                AttendanceTeam(id: 3, name: "Web Team", canManage: true)
            ]
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            return []
        }
    }

    public func fetchSessionAttendance(scheduleId: Int, teamId: Int) async throws -> [SessionAttendance] {
        sessionAttendanceCallCount += 1
        lastSessionAttendanceParams = (scheduleId: scheduleId, teamId: teamId)

        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .sessionAttendanceSuccess:
            return [
                SessionAttendance(id: 1, userId: 101, userName: "김개발", status: .present, team: .ios),
                SessionAttendance(id: 2, userId: 102, userName: "박코딩", status: .present, team: .ios),
                SessionAttendance(id: 3, userId: 103, userName: "이프로그래머", status: .present, team: .ios),
                SessionAttendance(id: 4, userId: 104, userName: "최개발자", status: .late, team: .ios),
                SessionAttendance(id: 5, userId: 105, userName: "정엔지니어", status: .absent, team: .ios)
            ]
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            return []
        }
    }

    public func fetchAttendanceStatuses() async throws -> [AttendanceStatus] {
        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .statusSuccess:
            return [.present, .late, .absent]
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            return []
        }
    }

    public func editAttendance(request: AttendanceEditRequest) async throws -> AttendanceEditResult {
        editCallCount += 1

        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .editSuccess, .statusChangeFlow, .permissionValidation, .historyTracking:
            return AttendanceEditResult(
                isSuccess: true,
                updatedAttendance: Attendance(
                    id: request.attendanceId,
                    userId: request.userId,
                    scheduleId: request.scheduleId,
                    status: request.newStatus,
                    modifiedAt: Date()
                )
            )
        case .permissionDenied:
            throw MockAttendanceError.permissionDenied
        case .invalidData:
            throw MockAttendanceError.invalidData
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            throw MockAttendanceError.unknownError
        }
    }

    public func calculateAttendanceStatistics(startDate: Date, endDate: Date) async throws -> AttendanceStatistics {
        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .statisticsSuccess:
            let totalSessions = 5
            let presentCount = 3
            let lateCount = 1
            let absentCount = 1
            let attendanceRate = Double(presentCount) / Double(totalSessions) * 100

            return AttendanceStatistics(
                totalSessions: totalSessions,
                presentCount: presentCount,
                lateCount: lateCount,
                absentCount: absentCount,
                attendanceRate: attendanceRate
            )
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            return AttendanceStatistics(totalSessions: 0, presentCount: 0, lateCount: 0, absentCount: 0, attendanceRate: 0.0)
        }
    }

    public func fetchTeamAttendance(teamType: Team) async throws -> [SessionAttendance] {
        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .teamFiltering:
            switch teamType {
            case .ios:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "iOS Member", status: .present, team: .ios), count: 8)
            case .android:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "Android Member", status: .present, team: .android), count: 6)
            case .web:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "Web Member", status: .present, team: .web), count: 4)
            case .design:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "Design Member", status: .present, team: .design), count: 3)
            }
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            return []
        }
    }

    public func validateAttendanceConsistency(scheduleId: Int, userId: Int) async throws -> AttendanceValidationResult {
        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .consistencyValidation:
            if scheduleId > 0 && userId > 0 {
                return AttendanceValidationResult(
                    isValid: true,
                    scheduleExists: true,
                    userExists: true,
                    attendanceRecordExists: true
                )
            } else {
                return AttendanceValidationResult(
                    isValid: false,
                    scheduleExists: false,
                    userExists: false,
                    attendanceRecordExists: false
                )
            }
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            return AttendanceValidationResult(isValid: false, scheduleExists: false, userExists: false, attendanceRecordExists: false)
        }
    }

    public func getAttendanceHistory(attendanceId: Int) async throws -> AttendanceHistory {
        try await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .historyTracking:
            // 수정 전 상태
            if editCallCount == 0 {
                return AttendanceHistory(
                    currentStatus: .absent,
                    previousStatus: nil,
                    modificationCount: 0,
                    lastModifiedDate: Date().addingTimeInterval(-3600) // 1시간 전
                )
            } else {
                // 수정 후 상태
                return AttendanceHistory(
                    currentStatus: .late,
                    previousStatus: .absent,
                    modificationCount: 1,
                    lastModifiedDate: Date() // 현재 시간
                )
            }
        case .networkError:
            throw MockAttendanceError.networkError
        default:
            return AttendanceHistory(currentStatus: .present, previousStatus: nil, modificationCount: 0, lastModifiedDate: Date())
        }
    }
}

// MARK: - Mock Data Types

public struct AdminAttendanceCount {
    public let totalSchedules: Int
    public let totalAttendees: Int
    public let presentCount: Int
    public let lateCount: Int
    public let absentCount: Int

    public init(totalSchedules: Int, totalAttendees: Int, presentCount: Int, lateCount: Int, absentCount: Int) {
        self.totalSchedules = totalSchedules
        self.totalAttendees = totalAttendees
        self.presentCount = presentCount
        self.lateCount = lateCount
        self.absentCount = absentCount
    }
}

public struct AttendanceTeam {
    public let id: Int
    public let name: String
    public let canManage: Bool

    public init(id: Int, name: String, canManage: Bool) {
        self.id = id
        self.name = name
        self.canManage = canManage
    }
}

public struct SessionAttendance {
    public let id: Int
    public let userId: Int
    public let userName: String
    public let status: AttendanceStatus
    public let team: Team

    public init(id: Int, userId: Int, userName: String, status: AttendanceStatus, team: Team) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.status = status
        self.team = team
    }
}

public struct AttendanceEditRequest {
    public let attendanceId: Int
    public let newStatus: AttendanceStatus
    public let scheduleId: Int
    public let userId: Int

    public init(attendanceId: Int, newStatus: AttendanceStatus, scheduleId: Int, userId: Int) {
        self.attendanceId = attendanceId
        self.newStatus = newStatus
        self.scheduleId = scheduleId
        self.userId = userId
    }
}

public struct AttendanceEditResult {
    public let isSuccess: Bool
    public let updatedAttendance: Attendance

    public init(isSuccess: Bool, updatedAttendance: Attendance) {
        self.isSuccess = isSuccess
        self.updatedAttendance = updatedAttendance
    }
}

public struct Attendance {
    public let id: Int
    public let userId: Int
    public let scheduleId: Int
    public let status: AttendanceStatus
    public let modifiedAt: Date

    public init(id: Int, userId: Int, scheduleId: Int, status: AttendanceStatus, modifiedAt: Date) {
        self.id = id
        self.userId = userId
        self.scheduleId = scheduleId
        self.status = status
        self.modifiedAt = modifiedAt
    }
}

public enum AttendanceStatus {
    case present
    case late
    case absent
}

public struct AttendanceStatistics {
    public let totalSessions: Int
    public let presentCount: Int
    public let lateCount: Int
    public let absentCount: Int
    public let attendanceRate: Double

    public init(totalSessions: Int, presentCount: Int, lateCount: Int, absentCount: Int, attendanceRate: Double) {
        self.totalSessions = totalSessions
        self.presentCount = presentCount
        self.lateCount = lateCount
        self.absentCount = absentCount
        self.attendanceRate = attendanceRate
    }
}

public struct AttendanceValidationResult {
    public let isValid: Bool
    public let scheduleExists: Bool
    public let userExists: Bool
    public let attendanceRecordExists: Bool

    public init(isValid: Bool, scheduleExists: Bool, userExists: Bool, attendanceRecordExists: Bool) {
        self.isValid = isValid
        self.scheduleExists = scheduleExists
        self.userExists = userExists
        self.attendanceRecordExists = attendanceRecordExists
    }
}

public struct AttendanceHistory {
    public let currentStatus: AttendanceStatus
    public let previousStatus: AttendanceStatus?
    public let modificationCount: Int
    public let lastModifiedDate: Date

    public init(currentStatus: AttendanceStatus, previousStatus: AttendanceStatus?, modificationCount: Int, lastModifiedDate: Date) {
        self.currentStatus = currentStatus
        self.previousStatus = previousStatus
        self.modificationCount = modificationCount
        self.lastModifiedDate = lastModifiedDate
    }
}

// MARK: - Mock Errors
public enum MockAttendanceError: Error, LocalizedError {
    case permissionDenied
    case invalidData
    case networkError
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission denied for attendance operation"
        case .invalidData:
            return "Invalid attendance data provided"
        case .networkError:
            return "Network error during attendance operation"
        case .unknownError:
            return "Unknown attendance error occurred"
        }
    }
}