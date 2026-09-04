import DDDStorageInterface
import Foundation
import SQLiteData

struct SQLiteSharedValueStorage: SharedValueStorage {
  let identifier = SharedValueStorageIdentifier()
  private let database: any DatabaseWriter

  init(database: any DatabaseWriter) {
    self.database = database
  }

  func load(forKey key: String) throws -> Data? {
    return try database.read { db in
      try Data.fetchOne(
        db,
        sql: "SELECT value FROM sharedValues WHERE key = ?",
        arguments: [key]
      )
    }
  }

  func save(_ data: Data, forKey key: String) throws {
    try database.write { db in
      try db.execute(
        sql: """
          INSERT INTO sharedValues (key, value) VALUES (?, ?)
          ON CONFLICT(key) DO UPDATE SET value = excluded.value
          """,
        arguments: [key, data]
      )
    }
  }

  func remove(forKey key: String) throws {
    try database.write { db in
      try db.execute(
        sql: "DELETE FROM sharedValues WHERE key = ?",
        arguments: [key]
      )
    }
  }
}
