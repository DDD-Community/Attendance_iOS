import SQLiteData

enum AppDatabaseMigrator {
  static func migrate(_ database: any DatabaseWriter) throws {
    var migrator = DatabaseMigrator()
    migrator.registerMigration("2026-09-04-create-shared-values") { db in
      try db.create(table: "sharedValues", ifNotExists: true) { table in
        table.column("key", .text).primaryKey()
        table.column("value", .blob).notNull()
      }
    }
    try migrator.migrate(database)
  }
}
