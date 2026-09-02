//
//  AuthenticatedClientProvider.swift
//  DDDAuthInterface
//
//  Created by DDD on 9/1/26.
//

import DDDNetworkInterface

/// `AuthService`와 같은 생명주기로 조립된 인증 네트워크 클라이언트를 제공한다.
public protocol AuthenticatedClientProvider: Sendable {
  /// 현재 인증 저장소와 토큰 재발급기를 공유하는 네트워크 클라이언트다.
  var authenticatedClient: any DDDNetworkClient { get }
}
