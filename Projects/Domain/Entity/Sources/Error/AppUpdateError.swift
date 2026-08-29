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
    case networkError(String)
    case decodingError
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .invalidBundleId:
            return "Bundle ID가 유효하지 않습니다."
        case .appNotFound:
            return "앱스토어에서 앱을 찾을 수 없습니다."
        case .networkError(let errorMessage):
            return "네트워크 오류: \(errorMessage)"
        case .decodingError:
            return "데이터 파싱 오류가 발생했습니다."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        }
    }

    public static func from(_ error: Error) -> AppUpdateError {
        if let appUpdateError = error as? AppUpdateError {
            return appUpdateError
        }
        return .networkError(error.localizedDescription)
    }
}
