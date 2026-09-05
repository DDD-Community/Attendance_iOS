//
//  StaffDelegate.swift
//  ManagementInterface
//
//  Created by DDD on 2026-09-02
//
//  Management 가 바깥에 알리는 위임 계약.
//
//  Management 밖으로 전달할 계약만 여기에 둔다.
//  동일 모듈 내부의 자식 Feature delegate는 구체 Feature에서 관리한다.
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum StaffDelegate: Equatable, Sendable {
  case presentSchedule
  case presentManagerProfile
}
