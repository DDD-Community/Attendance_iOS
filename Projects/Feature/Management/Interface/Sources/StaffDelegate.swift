//
//  StaffDelegate.swift
//  ManagementInterface
//
//  Created by DDD on 2026-09-02
//
//  Management 가 바깥에 알리는 위임 계약.
//
//  ScheduleReducer·QRCode·AttendanceCheck 의 DelegateAction 은 케이스가 비어 있어
//  옮길 계약이 없다. 계약이 생기면 여기로 온다.
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum StaffDelegate: Equatable, Sendable {
  case presentSchedule
  case presentManagerProfile
}
