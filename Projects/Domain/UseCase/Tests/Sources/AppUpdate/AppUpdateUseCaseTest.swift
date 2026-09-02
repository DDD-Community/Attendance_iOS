import ComposableArchitecture
import DomainInterface
import Entity
import Testing

@testable import UseCase

@Suite("AppUpdate UseCase")
struct AppUpdateUseCaseTest {
  @Test("업데이트가 필요하면 업데이트 정보를 반환한다")
  func returnsAvailableUpdate() async throws {
    let expected = AppUpdateInfo(
      currentVersion: "1.0.0",
      latestVersion: "1.1.0",
      releaseNotes: "새 기능",
      appStoreUrl: "https://apps.apple.com/app/id1",
      isUpdateAvailable: true
    )

    let result = try await withDependencies {
      $0.appUpdateRepository = AppUpdateRepositoryStub(result: .success(expected))
    } operation: {
      try await AppUpdateUseCaseImpl().checkForUpdate()
    }

    #expect(result == expected)
  }

  @Test("최신 버전이면 nil을 반환한다")
  func returnsNilWhenAlreadyCurrent() async throws {
    let current = AppUpdateInfo(
      currentVersion: "1.1.0",
      latestVersion: "1.1.0",
      releaseNotes: nil,
      appStoreUrl: "https://apps.apple.com/app/id1",
      isUpdateAvailable: false
    )

    let result = try await withDependencies {
      $0.appUpdateRepository = AppUpdateRepositoryStub(result: .success(current))
    } operation: {
      try await AppUpdateUseCaseImpl().checkForUpdate()
    }

    #expect(result == nil)
  }

  @Test("Repository 오류를 그대로 전달한다")
  func forwardsRepositoryError() async {
    await #expect(throws: AppUpdateError.lookupFailed) {
      try await withDependencies {
        $0.appUpdateRepository = AppUpdateRepositoryStub(result: .failure(.lookupFailed))
      } operation: {
        try await AppUpdateUseCaseImpl().checkForUpdate()
      }
    }
  }
}

private struct AppUpdateRepositoryStub: AppUpdateInterface {
  let result: Result<AppUpdateInfo, AppUpdateError>

  func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo {
    try result.get()
  }
}
