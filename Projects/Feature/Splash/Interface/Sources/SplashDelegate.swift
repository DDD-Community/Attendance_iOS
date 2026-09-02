//
//  SplashDelegate.swift
//  SplashInterface
//
//  Created by DDD on 2026-09-02
//
//  Splash 가 바깥에 알리는 위임 계약.
//  구현(Reducer·State·View)이 아니라 계약만 두므로, 이 피처를 띄우는 쪽은
//  SplashInterface 만 보고도 어떤 목적지가 나올 수 있는지 알 수 있다.
//  Splash 안에서는 typealias 로 받아 기존 `.delegate(.presentStaff)` 호출부를 그대로 쓴다.
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum SplashDelegate: Equatable, Sendable {
  case presentLogin
  case presentStaff
  case presentMember
}
