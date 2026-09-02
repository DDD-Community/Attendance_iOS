//
//  OnBoardingNavigation.swift
//  OnBoardingInterface
//
//  Created by DDD on 2026-09-02
//
//  OnBoarding 이 바깥에 알리는 이동 계약.
//  온보딩은 단계별 리듀서가 여러 개라 계약도 단계마다 둔다.
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum SelectTeamNavigation: Equatable, Sendable {
  case presentMember
  case presentManager
  case presentLogin
  case presentProfile
}

@CasePathable
public enum SelectManagingNavigation: Equatable, Sendable {
  case presentManager
  case presentMember
  case presentSelectTeam
  case presentProfile
}

@CasePathable
public enum SelectPartNavigation: Equatable, Sendable {
  case presentManaging
  case presentSelectTeam
  case presentNextStep
}

@CasePathable
public enum OnBoardingNameNavigation: Equatable, Sendable {
  case presentSignUpPart
}

@CasePathable
public enum InviteCodeNavigation: Equatable, Sendable {
  case presentSignUpName
}
