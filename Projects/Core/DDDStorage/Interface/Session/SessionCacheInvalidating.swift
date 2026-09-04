//
//  SessionCacheInvalidating.swift
//  DDDStorageInterface
//
//  Created by DDD on 9/4/26.
//

import Dependencies

public protocol SessionCacheInvalidating: Sendable {
  func invalidate() async
}

private struct NoopSessionCacheInvalidator: SessionCacheInvalidating {
  func invalidate() async {}
}

private enum SessionCacheInvalidatorKey: DependencyKey {
  static let liveValue: any SessionCacheInvalidating = NoopSessionCacheInvalidator()
  static let testValue: any SessionCacheInvalidating = NoopSessionCacheInvalidator()
  static let previewValue: any SessionCacheInvalidating = NoopSessionCacheInvalidator()
}

public extension DependencyValues {
  var sessionCacheInvalidator: any SessionCacheInvalidating {
    get { self[SessionCacheInvalidatorKey.self] }
    set { self[SessionCacheInvalidatorKey.self] = newValue }
  }
}
