//
//  ScheduleModalDelegate.swift
//  ManagementInterface
//
//  Created by DDD on 2026-09-03.
//

import ComposableArchitecture
import Entity
import Foundation

@CasePathable
public enum ScheduleModalDelegate: Equatable, Sendable {
  case selectScheduleCompleted(selectedSchedule: Schedule)
}
