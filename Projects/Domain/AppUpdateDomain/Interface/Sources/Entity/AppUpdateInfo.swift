//
//  AppUpdateInfo.swift
//  Entity
//
//  Created by DDD on 3/9/26.
//

import Foundation

public struct AppUpdateInfo: Codable, Equatable, Sendable {
    public let currentVersion: String
    public let latestVersion: String
    public let releaseNotes: String?
    public let appStoreUrl: String
    public let isUpdateAvailable: Bool
    /// 사용자에게 보여줄 버전.
    /// 릴리스 노트에 `[v 1.0.2]` 처럼 실제 배포 버전이 적혀 있으면 그것을 쓰고,
    /// 없으면 서버가 준 latestVersion 을 그대로 쓴다.
    /// 해석 규칙은 AppUpdateUseCase 가 갖는다. 서버 원본 값은 latestVersion 에 남긴다.
    public let displayVersion: String

    public init(
        currentVersion: String,
        latestVersion: String,
        releaseNotes: String?,
        appStoreUrl: String,
        isUpdateAvailable: Bool,
        displayVersion: String? = nil
    ) {
        self.currentVersion = currentVersion
        self.latestVersion = latestVersion
        self.releaseNotes = releaseNotes
        self.appStoreUrl = appStoreUrl
        self.isUpdateAvailable = isUpdateAvailable
        self.displayVersion = displayVersion ?? latestVersion
    }
}

public struct iTunesLookupResponse: Codable, Sendable {
    public let results: [iTunesAppInfo]

    public init(results: [iTunesAppInfo]) {
        self.results = results
    }
}

public struct iTunesAppInfo: Codable, Sendable {
    public let version: String
    public let releaseNotes: String?
    public let trackViewUrl: String

    public init(
        version: String,
        releaseNotes: String?,
        trackViewUrl: String
    ) {
        self.version = version
        self.releaseNotes = releaseNotes
        self.trackViewUrl = trackViewUrl
    }
}
