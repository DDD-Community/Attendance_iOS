//
//  StorageFactory.swift
//  DDDStorage
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface
import OSLog
import SQLiteData

public enum StorageFactory {
  public static var secureStorage: any SecureStorage {
    return KeychainStorage()
  }

  public static var sharedValueStorage: any SharedValueStorage {
    do {
      let database = try SQLiteData.defaultDatabase()
      try AppDatabaseMigrator.migrate(database)
      return SQLiteSharedValueStorage(database: database)
    } catch {
      Logger(subsystem: "io.dddstudy.attendance", category: "storage")
        .fault("Failed to prepare shared value database: \(String(describing: error), privacy: .public)")
      return VolatileSharedValueStorage()
    }
  }
}
