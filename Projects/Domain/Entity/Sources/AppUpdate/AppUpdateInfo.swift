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

    public init(
        currentVersion: String,
        latestVersion: String,
        releaseNotes: String?,
        appStoreUrl: String,
        isUpdateAvailable: Bool
    ) {
        self.currentVersion = currentVersion
        self.latestVersion = latestVersion
        self.releaseNotes = releaseNotes
        self.appStoreUrl = appStoreUrl
        self.isUpdateAvailable = isUpdateAvailable
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
