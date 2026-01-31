//
//  MockUserSession.swift
//  UseCaseTests
//
//  Created by TDD AI Automation on 2026-01-31
//

import Foundation
import Entity

@MainActor
public final class MockUserSession {

    // MARK: - Session Storage
    public var currentSession: UserSession
    public var staffRole: Staff?

    // MARK: - Change Tracking
    private(set) var sessionUpdateCount = 0
    private(set) var staffRoleUpdateCount = 0
    private var sessionHistory: [UserSession] = []
    private var staffRoleHistory: [Staff?] = []

    public init(
        initialSession: UserSession = .empty,
        initialStaffRole: Staff? = nil
    ) {
        self.currentSession = initialSession
        self.staffRole = initialStaffRole
    }

    // MARK: - Session Management
    public func updateSession(_ session: UserSession) {
        sessionUpdateCount += 1
        sessionHistory.append(currentSession)
        currentSession = session
    }

    public func updateStaffRole(_ role: Staff?) {
        staffRoleUpdateCount += 1
        staffRoleHistory.append(staffRole)
        staffRole = role
    }

    public func updateOAuthRefreshToken(_ token: String?) {
        sessionUpdateCount += 1
        sessionHistory.append(currentSession)
        currentSession = UserSession(
            userID: currentSession.userID,
            name: currentSession.name,
            selectPart: currentSession.selectPart,
            userRole: currentSession.userRole,
            managing: currentSession.managing,
            provider: currentSession.provider,
            selectTeam: currentSession.selectTeam,
            selectTeamId: currentSession.selectTeamId,
            token: currentSession.token,
            generationId: currentSession.generationId,
            accessToken: currentSession.accessToken,
            oauthRefreshToken: token,
            inviteCode: currentSession.inviteCode,
            generation: currentSession.generation
        )
    }

    // MARK: - Test Helpers
    public func reset() {
        currentSession = .empty
        staffRole = nil
        sessionUpdateCount = 0
        staffRoleUpdateCount = 0
        sessionHistory.removeAll()
        staffRoleHistory.removeAll()
    }

    public func setupNewUser(name: String, provider: SocialType) {
        currentSession = UserSession(
            userID: 0,
            name: name,
            selectPart: .all,
            userRole: .member,
            managing: [],
            provider: provider,
            selectTeam: .unknown,
            selectTeamId: nil,
            token: "",
            generationId: 0,
            accessToken: "",
            oauthRefreshToken: nil,
            inviteCode: "",
            generation: ""
        )
    }

    public func setupExistingUser(
        userID: Int = 123,
        name: String = "Existing User",
        role: Staff = .member,
        provider: SocialType = .google
    ) {
        currentSession = UserSession(
            userID: userID,
            name: name,
            selectPart: .development,
            userRole: role,
            managing: [],
            provider: provider,
            selectTeam: .teamA,
            selectTeamId: 1,
            token: "existing_token",
            generationId: 1,
            accessToken: "existing_access_token",
            oauthRefreshToken: provider == .apple ? nil : "existing_oauth_token",
            inviteCode: "ABC123",
            generation: "1기"
        )
        staffRole = role
    }

    // MARK: - Verification Helpers
    public func wasSessionUpdated() -> Bool {
        return sessionUpdateCount > 0
    }

    public func wasStaffRoleUpdated() -> Bool {
        return staffRoleUpdateCount > 0
    }

    public func getPreviousSession() -> UserSession? {
        return sessionHistory.last
    }

    public func getPreviousStaffRole() -> Staff?? {
        return staffRoleHistory.last
    }

    public func hasOAuthRefreshToken() -> Bool {
        return currentSession.oauthRefreshToken != nil
    }

    public func verifyOAuthRefreshToken(_ expectedToken: String?) -> Bool {
        return currentSession.oauthRefreshToken == expectedToken
    }
}

// MARK: - UserSession Test Extensions
public extension UserSession {
    static func makeTestSession(
        userID: Int = 123,
        name: String = "Test User",
        provider: SocialType = .google,
        role: Staff = .member,
        isNewUser: Bool = false
    ) -> UserSession {
        return UserSession(
            userID: isNewUser ? 0 : userID,
            name: name,
            selectPart: isNewUser ? .all : .development,
            userRole: role,
            managing: [],
            provider: provider,
            selectTeam: isNewUser ? .unknown : .teamA,
            selectTeamId: isNewUser ? nil : 1,
            token: isNewUser ? "" : "test_token",
            generationId: isNewUser ? 0 : 1,
            accessToken: "",
            oauthRefreshToken: provider == .apple ? nil : "test_oauth_token",
            inviteCode: isNewUser ? "" : "ABC123",
            generation: isNewUser ? "" : "1기"
        )
    }

    static let mockAppleUser = UserSession(
        userID: 456,
        name: "Apple User",
        selectPart: .design,
        userRole: .manager,
        managing: [.development, .design],
        provider: .apple,
        selectTeam: .teamB,
        selectTeamId: 2,
        token: "apple_token",
        generationId: 2,
        accessToken: "apple_access_token",
        oauthRefreshToken: nil, // Apple doesn't provide OAuth refresh token
        inviteCode: "XYZ789",
        generation: "2기"
    )

    static let mockGoogleUser = UserSession(
        userID: 789,
        name: "Google User",
        selectPart: .development,
        userRole: .member,
        managing: [],
        provider: .google,
        selectTeam: .teamC,
        selectTeamId: 3,
        token: "google_token",
        generationId: 1,
        accessToken: "google_access_token",
        oauthRefreshToken: "google_oauth_refresh",
        inviteCode: "DEF456",
        generation: "1기"
    )
}