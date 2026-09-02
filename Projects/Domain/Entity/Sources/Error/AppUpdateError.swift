//
//  AppUpdateError.swift
//  Entity
//
//  Created by DDD on 3/9/26.
//

import Foundation

public enum AppUpdateError: Error, LocalizedError, Sendable, Equatable {
    case invalidBundleId
    case appNotFound
    case lookupFailed
    case invalidResponse
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .invalidBundleId:
            return "Bundle ID가 유효하지 않습니다."
        case .appNotFound:
            return "앱스토어에서 앱을 찾을 수 없습니다."
        case .lookupFailed:
            return "앱 업데이트 정보를 불러오지 못했습니다."
        case .invalidResponse:
            return "앱스토어 응답을 처리하지 못했습니다."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        }
    }

    public static func from(_ error: Error) -> AppUpdateError {
        if let appUpdateError = error as? AppUpdateError {
            return appUpdateError
        }
        return .unknownError
    }
}
