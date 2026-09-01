//
//  ProfileLocalDataSource.swift
//  Repository
//
//  Created by DDD on 5/12/26.
//

import Foundation
import SwiftData

import Entity

import Dependencies

public protocol ProfileLocalDataSourceProtocol: Actor {
  func loadUser() async throws(ProfileError) -> ProfileEntity?
  func saveUser(_ profile: ProfileEntity) async throws(ProfileError)
  func clear() async throws(ProfileError)
}

public actor ProfileLocalDataSource: ProfileLocalDataSourceProtocol {
  private let container: ModelContainer

  public init(container: ModelContainer? = nil) {
    if let container {
      self.container = container
    } else {
      let schema = Schema([ProfileCacheEntity.self])
      do {
        self.container = try ModelContainer(
          for: schema,
          configurations: ModelConfiguration(
            isStoredInMemoryOnly: false
          )
        )
      } catch {
        fatalError("Failed to create Profile cache container: \(error)")
      }
    }
  }

  public func loadUser() async throws(ProfileError) -> ProfileEntity? {
    do {
      let context = makeContext()
      guard let cache = try fetchCache(in: context) else {
        return nil
      }
      if cache.isExpired {
        context.delete(cache)
        try context.save()
        return nil
      }
      return cache.toDomain()
    } catch {
      throw ProfileError.from(error)
    }
  }

  public func saveUser(_ profile: ProfileEntity) async throws(ProfileError) {
    do {
      let context = makeContext()
      if let existing = try fetchCache(in: context) {
        context.delete(existing)
      }
      context.insert(profile.toCacheModel(cacheKey: ProfileCacheKey.user))
      try context.save()
    } catch {
      throw ProfileError.from(error)
    }
  }

  public func clear() async throws(ProfileError) {
    do {
      let context = makeContext()
      try context.delete(model: ProfileCacheEntity.self)
      try context.save()
    } catch {
      throw ProfileError.from(error)
    }
  }
}

private extension ProfileLocalDataSource {
  func makeContext() -> ModelContext {
    ModelContext(container)
  }

  func fetchCache(in context: ModelContext) throws -> ProfileCacheEntity? {
    var descriptor = FetchDescriptor<ProfileCacheEntity>(
      predicate: #Predicate { $0.cacheKey == "profile.user.default" }
    )
    descriptor.fetchLimit = 1
    return try context.fetch(descriptor).first
  }
}

/// ProfileLocalDataSource의 DependencyKey 구조체
public enum ProfileLocalDataSourceDependency: DependencyKey {
  public static var liveValue: ProfileLocalDataSourceProtocol {
    ProfileLocalDataSource()
  }

  public static var testValue: ProfileLocalDataSourceProtocol = liveValue

  public static var previewValue: ProfileLocalDataSourceProtocol = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var profileLocalDataSource: ProfileLocalDataSourceProtocol {
    get { self[ProfileLocalDataSourceDependency.self] }
    set { self[ProfileLocalDataSourceDependency.self] = newValue }
  }
}
