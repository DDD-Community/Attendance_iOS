//
//  ProfileNavigation.swift
//  ProfileInterface
//
//  Created by DDD on 2026-09-02
//
//  Profile 이 바깥에 알리는 이동 계약.
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum ProfileNavigation: Equatable, Sendable {
  case presentLogOut
  case presentCreateByApp
  case presentPrivacyPolicy
  case presentEditGeneration
  case presentAppPeedBackWeb
}

@CasePathable
public enum CreateAppNavigation: Equatable, Sendable {
  case presentWeb
}
