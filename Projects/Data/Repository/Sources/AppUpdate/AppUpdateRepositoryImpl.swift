//
//  AppUpdateRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh on 3/9/26.
//

import Foundation
import DomainInterface
import Entity
import Model
import LogMacro

public final class AppUpdateRepositoryImpl: AppUpdateInterface {
    private let urlSession: URLSession
    private let bundleId: String

    public init(
        urlSession: URLSession = .shared,
        bundleId: String? = nil
    ) {
        self.urlSession = urlSession
        self.bundleId = bundleId ?? Bundle.main.bundleIdentifier ?? ""
    }

    public func checkForUpdate() async throws -> AppUpdateInfo {
        guard !bundleId.isEmpty else {
            throw AppUpdateError.invalidBundleId
        }

        let currentVersion = getCurrentAppVersion()
        let appStoreInfo = try await fetchAppStoreInfo()

        return appStoreInfo.toEntity(currentVersion: currentVersion)
    }

    // MARK: - Private Methods

    private func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private func getCurrentAppLanguage() -> String {
        // 1. 현재 Locale의 언어 코드 확인
        if let languageCode = Locale.current.language.languageCode?.identifier {
            return languageCode
        }

        // 2. 시스템 선호 언어 확인
        if let preferredLanguage = NSLocale.preferredLanguages.first {
            let language = String(preferredLanguage.prefix(2))
            return language
        }

        // 3. Bundle의 기본 언어 확인
        if let bundleLanguage = Bundle.main.preferredLocalizations.first {
            let language = String(bundleLanguage.prefix(2))
            return language
        }

        // 4. 최종 fallback - 영어
        return "en"
    }

    private func fetchAppStoreInfo() async throws -> AppStoreInfoDTO {
        let currentLanguage = getCurrentAppLanguage()
        #logDebug("[AppUpdate] Current app language", currentLanguage)

        // 언어에 따른 우선순위 결정
        let primaryCountry = currentLanguage == "ko" ? "kr" : "us"
        let fallbackCountry = currentLanguage == "ko" ? "us" : "kr"

        // 우선 스토어 시도
        if let result = try? await fetchAppStoreInfo(country: primaryCountry) {
            #logDebug("[AppUpdate] Using \(primaryCountry) store result")
            return result
        }

        // 폴백 스토어 시도
        #logDebug("[AppUpdate] \(primaryCountry) store failed, trying \(fallbackCountry)")
        let fallbackResult = try await fetchAppStoreInfo(country: fallbackCountry)
        #logDebug("[AppUpdate] Using \(fallbackCountry) store as fallback")
        return fallbackResult
    }

    private func fetchAppStoreInfo(country: String) async throws -> AppStoreInfoDTO {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=\(country)"
        guard let url = URL(string: urlString) else {
            throw AppUpdateError.invalidBundleId
        }

        do {
            let (data, _) = try await urlSession.data(from: url)
            let response = try JSONDecoder().decode(AppUpdateResponseDTO.self, from: data)

            guard let appInfo = response.results.first else {
                throw AppUpdateError.appNotFound
            }

            return appInfo
        } catch let decodingError as DecodingError {
            #logError("[AppUpdate] Decoding error for \(country)", decodingError.localizedDescription)
            throw AppUpdateError.decodingError
        } catch {
            #logError("[AppUpdate] Network error for \(country)", error.localizedDescription)
            throw AppUpdateError.from(error)
        }
    }
}
