//
//  NetworkClientDependency.swift
//  DDDNetworkInterface
//
//  Created by DDD on 2026-09-02
//
//  네트워크 클라이언트의 DependencyKey.
//
//  예전에는 Repository 마다 생성자로 client 를 받았고, RepositoryFactory 가
//  같은 `client: networkClient` 를 아홉 번 반복해 넘겼다. 조립 지점이 한 곳뿐이라
//  호출부마다 다른 클라이언트를 넣는 일이 없었으므로 생성자 주입의 이점을 쓰지 않았다.
//  UseCase·Repository 가 이미 DependencyValues 로 등록되는 것과도 방식이 어긋났다.
//
//  liveValue 는 인증 헤더를 붙이는 실제 클라이언트라 상위 조립 레이어(ServiceAssembly)가
//  등록한다. 여기서는 계약과 테스트값만 둔다.
//

import Dependencies
import Foundation

public enum NetworkClientDependency: TestDependencyKey {
  public static var testValue: any DDDNetworkClient {
    UnimplementedNetworkClient()
  }
}

public extension DependencyValues {
  var networkClient: any DDDNetworkClient {
    get { self[NetworkClientDependency.self] }
    set { self[NetworkClientDependency.self] = newValue }
  }
}

/// 테스트에서 클라이언트를 갈아끼우지 않은 채 네트워크를 타면 알려주는 기본값.
/// 조용히 빈 응답을 돌려주면 테스트가 통과해버려 누락을 놓친다.
public struct UnimplementedNetworkClient: DDDNetworkClient {
  public init() {}

  public func send<R: DDDDataRequest, T: Decodable & Sendable>(
    _ request: R,
    as type: T.Type
  ) async throws(DDDNetworkError) -> T {
    reportUnimplemented()
  }

  public func send<R: DDDDataRequest>(_ request: R) async throws(DDDNetworkError) -> R.Response {
    reportUnimplemented()
  }

  public func sendResponse<R: DDDDataRequest>(
    _ request: R
  ) async throws(DDDNetworkError) -> DDDHTTPResponse {
    reportUnimplemented()
  }

  public func upload<R: DDDUploadRequest>(_ request: R) async throws(DDDNetworkError) -> R.Response {
    reportUnimplemented()
  }

  public func upload(_ request: some DDDFileUploadRequest) async throws(DDDNetworkError) {
    reportUnimplemented()
  }

  private func reportUnimplemented() -> Never {
    fatalError(
      "networkClient 가 등록되지 않았다. 테스트라면 withDependencies 로 스텁을 넣고, "
        + "앱이라면 ServiceAssembly 의 liveValue 등록을 확인할 것."
    )
  }
}
