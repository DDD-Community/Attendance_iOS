import Foundation
import Testing

@testable import AppUpdateDomain
@testable import AttendanceDomain
@testable import AuthDomain
@testable import MyPageDomain
@testable import OnBoardingDomain
@testable import ProfileDomain
@testable import QRCodeDomain
@testable import ScheduleDomain
@testable import VoteDomain

@Suite("AppUpdateRepositoryImpl", .serialized)
struct AppUpdateRepositoryImplTests {
  @Test("빈 Bundle ID는 요청 없이 실패한다")
  func rejectsEmptyBundleID() async {
    AppUpdateURLProtocolStub.configure([])
    let repository = makeRepository(bundleID: "")

    await #expect(throws: AppUpdateError.invalidBundleId) {
      try await repository.checkForUpdate()
    }
    #expect(AppUpdateURLProtocolStub.recordedRequests.isEmpty)
  }

  @Test("현재 언어의 App Store 조회가 성공하면 업데이트 정보를 반환한다")
  func returnsAppStoreInfoFromPrimaryCountry() async throws {
    AppUpdateURLProtocolStub.configure([.response(appStoreResponse())])
    let repository = makeRepository()

    let result = try await repository.checkForUpdate()

    #expect(result.latestVersion == "99.0.0")
    #expect(result.releaseNotes == "새로운 출석 기능")
    #expect(result.appStoreUrl == "https://apps.apple.com/app/id123")
    #expect(result.isUpdateAvailable)
    #expect(AppUpdateURLProtocolStub.recordedRequests.count == 1)
    #expect(requestedCountries().allSatisfy { $0 == "kr" || $0 == "us" })
  }

  @Test("첫 App Store 조회가 실패하면 한국과 미국 Store를 순서대로 조회한다")
  func fallsBackBetweenKoreanAndUnitedStatesStores() async throws {
    AppUpdateURLProtocolStub.configure([
      .failure(URLError(.notConnectedToInternet)),
      .response(appStoreResponse(version: "100.0.0"))
    ])
    let repository = makeRepository()

    let result = try await repository.checkForUpdate()

    #expect(result.latestVersion == "100.0.0")
    #expect(requestedCountries().count == 2)
    #expect(Set(requestedCountries()) == Set(["kr", "us"]))
  }

  @Test("두 Store가 잘못된 JSON을 반환하면 invalidResponse를 전달한다")
  func rejectsInvalidJSON() async {
    let invalidJSON = Data("not-json".utf8)
    AppUpdateURLProtocolStub.configure([
      .response(invalidJSON),
      .response(invalidJSON)
    ])
    let repository = makeRepository()

    await #expect(throws: AppUpdateError.invalidResponse) {
      try await repository.checkForUpdate()
    }
    #expect(AppUpdateURLProtocolStub.recordedRequests.count == 2)
  }

  @Test("두 Store의 검색 결과가 비어 있으면 appNotFound를 전달한다")
  func rejectsEmptyResults() async {
    let emptyResponse = Data(#"{"resultCount":0,"results":[]}"#.utf8)
    AppUpdateURLProtocolStub.configure([
      .response(emptyResponse),
      .response(emptyResponse)
    ])
    let repository = makeRepository()

    await #expect(throws: AppUpdateError.appNotFound) {
      try await repository.checkForUpdate()
    }
    #expect(AppUpdateURLProtocolStub.recordedRequests.count == 2)
  }

  @Test("두 Store의 네트워크 요청이 실패하면 lookupFailed를 전달한다")
  func forwardsNetworkFailure() async {
    AppUpdateURLProtocolStub.configure([
      .failure(URLError(.timedOut)),
      .failure(URLError(.notConnectedToInternet))
    ])
    let repository = makeRepository()

    await #expect(throws: AppUpdateError.lookupFailed) {
      try await repository.checkForUpdate()
    }
    #expect(AppUpdateURLProtocolStub.recordedRequests.count == 2)
  }

  private func makeRepository(bundleID: String = "com.ddd.attendance") -> AppUpdateRepositoryImpl {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [AppUpdateURLProtocolStub.self]
    return AppUpdateRepositoryImpl(
      urlSession: URLSession(configuration: configuration),
      bundleId: bundleID
    )
  }

  private func requestedCountries() -> [String] {
    AppUpdateURLProtocolStub.recordedRequests.compactMap { request in
      URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?
        .queryItems?
        .first(where: { $0.name == "country" })?
        .value
    }
  }

  private func appStoreResponse(version: String = "99.0.0") -> Data {
    Data(
      #"{"resultCount":1,"results":[{"version":"\#(version)","releaseNotes":"새로운 출석 기능","trackViewUrl":"https://apps.apple.com/app/id123","bundleId":"com.ddd.attendance","trackName":"DDD 출석"}]}"#.utf8
    )
  }
}

private final class AppUpdateURLProtocolStub: URLProtocol, @unchecked Sendable {
  enum Stub: @unchecked Sendable {
    case response(Data)
    case failure(Error)
  }

  private nonisolated(unsafe) static var stubs: [Stub] = []
  private nonisolated(unsafe) static var requests: [URLRequest] = []
  private static let lock = NSLock()

  static func configure(_ stubs: [Stub]) {
    lock.withLock {
      self.stubs = stubs
      requests = []
    }
  }

  static var recordedRequests: [URLRequest] {
    lock.withLock { requests }
  }

  override class func canInit(with _: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    let stub = Self.lock.withLock { () -> Stub? in
      Self.requests.append(request)
      guard !Self.stubs.isEmpty else { return nil }
      return Self.stubs.removeFirst()
    }

    guard let stub else {
      client?.urlProtocol(self, didFailWithError: URLError(.unknown))
      return
    }

    switch stub {
    case .response(let data):
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)

    case .failure(let error):
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}
