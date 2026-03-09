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
        // 한국과 미국 앱스토어 정보를 동시에 가져오기
        async let koTask = fetchAppStoreInfo(country: "kr")
        async let usTask = fetchAppStoreInfo(country: "us")

        do {
            let koResult = try await koTask
            #logDebug("[AppUpdate] Korean store result", koResult)

            do {
                let usResult = try await usTask
                #logDebug("[AppUpdate] US store result", usResult)

                // 앱 언어 설정에 따라 적절한 버전 선택
                let currentLanguage = getCurrentAppLanguage()
                #logDebug("[AppUpdate] Current app language", currentLanguage)

                if currentLanguage == "ko" {
                    #logDebug("[AppUpdate] Using Korean version (app language: ko)")
                    return koResult
                } else {
                    #logDebug("[AppUpdate] Using US version (app language: \(currentLanguage))")
                    return usResult
                }
            } catch {
                #logDebug("[AppUpdate] US store failed, using Korean result")
                return koResult
            }
        } catch {
            #logDebug("[AppUpdate] Korean store failed, trying US only")

            do {
                let usResult = try await usTask
                #logDebug("[AppUpdate] Using US store as fallback")
                return usResult
            } catch {
                #logError("[AppUpdate] Both stores failed", error.localizedDescription)
                throw error
            }
        }
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
