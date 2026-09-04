//
//  AppUpdateDTO.swift
//  AppUpdateDomain
//
//  Created by DDD on 3/9/26.
//

import Foundation

public struct AppUpdateResponseDTO: Codable, Sendable {
    public let resultCount: Int
    public let results: [AppStoreInfoDTO]

    public init(resultCount: Int, results: [AppStoreInfoDTO]) {
        self.resultCount = resultCount
        self.results = results
    }
}

public struct AppStoreInfoDTO: Codable, Sendable {
    public let version: String
    public let releaseNotes: String?
    public let trackViewUrl: String
    public let bundleId: String
    public let trackName: String

    public init(
        version: String,
        releaseNotes: String?,
        trackViewUrl: String,
        bundleId: String,
        trackName: String
    ) {
        self.version = version
        self.releaseNotes = releaseNotes
        self.trackViewUrl = trackViewUrl
        self.bundleId = bundleId
        self.trackName = trackName
    }
}