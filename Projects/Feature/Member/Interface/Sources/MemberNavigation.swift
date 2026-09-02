//
//  MemberNavigation.swift
//  MemberInterface
//
//  Created by DDD on 2026-09-02
//
//  Member 가 바깥에 알리는 이동 계약.
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum MemberMainNavigation: Equatable, Sendable {
  case routeToQRCode
  case routeToProfile
}

@CasePathable
public enum MemberQRCodeNavigation: Equatable, Sendable {
  case back
}
