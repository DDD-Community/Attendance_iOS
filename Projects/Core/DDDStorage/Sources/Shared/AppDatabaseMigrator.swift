//
//  AppDatabaseMigrator.swift
//  DDDStorage
//
//  Created by DDD on 9/4/26.
//

import SQLiteData

enum AppDatabaseMigrator {
  static func migrate(_ database: any DatabaseWriter) throws {
    var migrator = DatabaseMigrator()
    migrator.registerMigration("2026-09-04-create-shared-values") { db in
      try #sql(
        """
          CREATE TABLE IF NOT EXISTS sharedValues (
            key TEXT PRIMARY KEY NOT NULL,
            value BLOB NOT NULL
          )
          """
      )
      .execute(db)
    }
    migrator.registerMigration("2026-09-04-create-domain-caches") { db in
      try #sql(
        """
          CREATE TABLE IF NOT EXISTS profileCache (
            cacheKey TEXT PRIMARY KEY NOT NULL,
            cachedAt INTEGER NOT NULL,
            userID INTEGER NOT NULL,
            name TEXT NOT NULL,
            generation TEXT NOT NULL,
            teamRawValue TEXT,
            jobRoleRawValue TEXT NOT NULL,
            roleRawValue TEXT NOT NULL,
            managerRolesData BLOB
          )
          """
      )
      .execute(db)
      try #sql(
        """
          CREATE TABLE IF NOT EXISTS scheduleCache (
            id INTEGER PRIMARY KEY NOT NULL,
            cachedAt INTEGER NOT NULL,
            name TEXT NOT NULL,
            scheduleDescription TEXT NOT NULL,
            month INTEGER NOT NULL,
            day INTEGER NOT NULL,
            year INTEGER NOT NULL
          )
          """
      )
      .execute(db)
    }
    migrator.registerMigration("2026-09-04-normalize-domain-cache-dates") { db in
      // 캐시는 재조회 가능한 데이터이므로 이전 REAL 날짜 형식은 보존하지 않는다.
      try #sql("DELETE FROM profileCache").execute(db)
      try #sql("DELETE FROM scheduleCache").execute(db)
    }
    try migrator.migrate(database)
  }
}
