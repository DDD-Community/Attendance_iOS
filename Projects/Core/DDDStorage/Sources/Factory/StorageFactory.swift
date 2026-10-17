//
//  StorageFactory.swift
//  DDDStorage
//
//  Created by DDD on 9/1/26.
//

import OSLog

import DDDStorageInterface

import Dependencies
import SQLiteData

public enum StorageFactory {
  private static let database = prepareDatabase()

  static func prepareDatabase(
    primary: () throws -> any DatabaseWriter = { try SQLiteData.defaultDatabase() },
    fallback: () throws -> any DatabaseWriter = { try DatabaseQueue() },
    migrate: (any DatabaseWriter) throws -> Void = AppDatabaseMigrator.migrate,
    importLegacy: (any DatabaseWriter) throws -> Void = { try LegacySwiftDataMigration.migrate(into: $0) }
  ) -> (any DatabaseWriter)? {
    do {
      let database = try primary()
      try migrate(database)
      do {
        try importLegacy(database)
      } catch {
        // 이전 캐시 손상은 정상적인 현재 DB를 메모리 DB로 교체할 이유가 아니다.
        Logger(subsystem: "io.dddstudy.attendance", category: "storage")
          .error("Legacy cache import failed: \(String(describing: error), privacy: .public)")
      }
      return database
    } catch {
      Logger(subsystem: "io.dddstudy.attendance", category: "storage")
        .fault("Failed to prepare app database: \(String(describing: error), privacy: .public)")
    }

    do {
      let database = try fallback()
      try migrate(database)
      return database
    } catch {
      Logger(subsystem: "io.dddstudy.attendance", category: "storage")
        .fault("Failed to prepare in-memory database: \(String(describing: error), privacy: .public)")
      return nil
    }
  }

  public static var secureStorage: any SecureStorage {
    return KeychainStorage()
  }

  public static var sharedValueStorage: any SharedValueStorage {
    guard let database else {
      return VolatileSharedValueStorage()
    }
    return SQLiteSharedValueStorage(database: database)
  }

  public static var databaseWriter: (any DatabaseWriter)? {
    database
  }

  public static func register(into values: inout DependencyValues) {
    if let database {
      values.defaultDatabase = database
      values.appDatabase = database
    }
    values.sharedValueStorage = sharedValueStorage
  }
}
