//
//  DefaultAppUpdateRepositoryImpl.swift
//  DomainInterface
//
//  Created by DDD on 3/9/26.
//

import Foundation
import Entity

public final class DefaultAppUpdateRepositoryImpl: AppUpdateInterface {
    public init() {}

    public func checkForUpdate() async throws -> AppUpdateInfo {
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