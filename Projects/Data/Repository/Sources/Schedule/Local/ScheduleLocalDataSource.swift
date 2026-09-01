//
//  ScheduleLocalDataSource.swift
//  Repository
//
//  Created by DDD on 5/12/26.
//

import Foundation
import SwiftData

import Entity

import Dependencies

public protocol ScheduleLocalDataSourceProtocol: Actor {
  func loadAll() async throws(ScheduleError) -> [Schedule]?
  func saveAll(_ schedules: [Schedule]) async throws(ScheduleError)
  func clear() async throws(ScheduleError)
}

public actor ScheduleLocalDataSource: ScheduleLocalDataSourceProtocol {
  private let container: ModelContainer

  public init(container: ModelContainer? = nil) {
    if let container {
      self.container = container
    } else {
      let schema = Schema([ScheduleCacheEntity.self])
      do {
        self.container = try ModelContainer(
          for: schema,
          configurations: ModelConfiguration(
            isStoredInMemoryOnly: false
          )
        )
      } catch {
        fatalError("Failed to create Schedule cache container: \(error)")
      }
    }
  }

  public func loadAll() async throws(ScheduleError) -> [Schedule]? {
    do {
      let context = makeContext()
      let descriptor = FetchDescriptor<ScheduleCacheEntity>(
        sortBy: [
          SortDescriptor(\.year, order: .forward),
          SortDescriptor(\.month, order: .forward),
          SortDescriptor(\.day, order: .forward)
        ]
      )
      let cached = try context.fetch(descriptor)
      guard !cached.isEmpty else { return nil }

      if cached.contains(where: { $0.isExpired }) {
        try context.delete(model: ScheduleCacheEntity.self)
        try context.save()
        return nil
      }
      return cached.map { $0.toDomain() }
    } catch {
      throw ScheduleError.from(error)
    }
  }

  public func saveAll(_ schedules: [Schedule]) async throws(ScheduleError) {
    do {
      let context = makeContext()
      try context.delete(model: ScheduleCacheEntity.self)
      let now = Date()
      for schedule in schedules {
        context.insert(schedule.toCacheModel(cachedAt: now))
      }
      try context.save()
    } catch {
      throw ScheduleError.from(error)
    }
  }

  public func clear() async throws(ScheduleError) {
    do {
      let context = makeContext()
      try context.delete(model: ScheduleCacheEntity.self)
      try context.save()
    } catch {
      throw ScheduleError.from(error)
    }
  }
}

private extension ScheduleLocalDataSource {
  func makeContext() -> ModelContext {
    ModelContext(container)
  }
}

/// ScheduleLocalDataSource의 DependencyKey 구조체
public enum ScheduleLocalDataSourceDependency: DependencyKey {
  public static var liveValue: ScheduleLocalDataSourceProtocol {
    ScheduleLocalDataSource()
  }

  public static var testValue: ScheduleLocalDataSourceProtocol = liveValue

  public static var previewValue: ScheduleLocalDataSourceProtocol = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var scheduleLocalDataSource: ScheduleLocalDataSourceProtocol {
    get { self[ScheduleLocalDataSourceDependency.self] }
    set { self[ScheduleLocalDataSourceDependency.self] = newValue }
  }
}
