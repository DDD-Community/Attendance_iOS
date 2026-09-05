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
    SQLiteSharedValueStorage(database: databaseWriter)
  }

  public static var databaseWriter: any DatabaseWriter {
    database ?? fallbackDatabase
  }

  public static func register(into values: inout DependencyValues) {
    values.defaultDatabase = databaseWriter
    values.appDatabase = databaseWriter
    values.sharedValueStorage = sharedValueStorage
  }

  private static let fallbackDatabase: any DatabaseWriter = {
    let database = try! SQLiteData.defaultDatabase()
    try? AppDatabaseMigrator.migrate(database)
    return database
  }()
}
