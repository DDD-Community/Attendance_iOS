//
//  DefaultHeaders.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Alamofire
import Foundation

/// 모든 요청에 공통으로 박히는 정적 헤더.
/// 요청별 헤더는 `DDDEndpoint.headers`, 토큰은 `DDDAuthenticator` 가 붙인다.
/// Content-Type 은 인코더 / 멀티파트가 요청마다 정하므로 여기서 고정하지 않는다.
struct DefaultHeaders {
  let appVersion: String

  init(appVersion: String = DefaultHeaders.bundleAppVersion) {
    self.appVersion = appVersion
  }

  var headers: HTTPHeaders {
    var headers = HTTPHeaders.default
    headers.add(name: "Accept", value: "application/json")
    headers.add(name: "app-version", value: appVersion)
    return headers
  }

  private static var bundleAppVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
  }
}
