//
//  MockAppUpdateRepository.swift
//  DomainInterface
//
//  Created by DDD on 3/9/26.
//

import Foundation

public final class MockAppUpdateRepository: AppUpdateInterface {
    public init() {}

    public func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo {
        // Mock implementation - 실제 구현은 Repository에서
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

        return AppUpdateInfo(
            currentVersion: currentVersion,
            latestVersion: currentVersion,
            releaseNotes: nil,
            appStoreUrl: "https://apps.apple.com",
            isUpdateAvailable: false
        )
    }
}