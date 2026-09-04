//
//  StorageFactory.swift
//  DDDStorage
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface
import Dependencies
import OSLog
import SQLiteData

public enum StorageFactory {
  private static let database: (any DatabaseWriter)? = {
    do {
      let database = try SQLiteData.defaultDatabase()
      try AppDatabaseMigrator.migrate(database)
      return database
    } catch {
      Logger(subsystem: "io.dddstudy.attendance", category: "storage")
        .fault("Failed to prepare app database: \(String(describing: error), privacy: .public)")
      return nil
    }
  }()

  public static var secureStorage: any SecureStorage {
    return KeychainStorage()
  }

  public static var sharedValueStorage: any SharedValueStorage {
    if let database {
      return SQLiteSharedValueStorage(database: database)
    }
    return VolatileSharedValueStorage()
  }

  public static func register(into values: inout DependencyValues) {
    guard let database else {
      values.sharedValueStorage = VolatileSharedValueStorage()
      return
    }
    values.defaultDatabase = database
    values.sharedValueStorage = SQLiteSharedValueStorage(database: database)
  }
}
