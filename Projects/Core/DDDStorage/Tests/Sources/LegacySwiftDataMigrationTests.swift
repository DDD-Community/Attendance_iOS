@testable import DDDStorage
import DDDStorageInterface
import Foundation
import SQLiteData
import SwiftData
import Testing

@Suite("1.0.9 SwiftData migration", .serialized)
@MainActor
struct LegacySwiftDataMigrationTests {
  @Test("WAL에만 커밋된 데이터도 가져오며 원본 DB와 WAL을 보존한다")
  func importsUncheckpointedWAL() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appendingPathComponent("default.store")
    let schema = Schema([ProfileCacheEntity.self])
    let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let context = ModelContext(container)
    context.autosaveEnabled = false
    let originalDB = try Data(contentsOf: url)
    context.insert(ProfileCacheEntity(
      cacheKey: "profile.user.default", cachedAt: Date(timeIntervalSince1970: 1_780_000_000),
      userID: 42, name: "WAL 사용자", generation: "12기", teamRawValue: nil,
      jobRoleRawValue: "ios", roleRawValue: "manager", managerRolesRawValues: nil
    ))
    try context.save()
    // 본체에 반영되지 않은 커밋이 WAL에 남아 있는 상태임을 확인한다.
    #expect(try Data(contentsOf: url) == originalDB)
    let walURL = URL(fileURLWithPath: url.path + "-wal")
    let originalWAL = try Data(contentsOf: walURL)
    #expect(originalWAL.count > 32)
    let database = try makeDatabase()

    try withExtendedLifetime(container) {
      try LegacySwiftDataMigration.migrate(into: database, sourceURL: url, legacyRole: "manager")
      #expect(try database.read {
        try #sql("SELECT name FROM profileCache", as: String.self).fetchOne($0)
      } == "WAL 사용자")
      #expect(try Data(contentsOf: url) == originalDB)
      #expect(try Data(contentsOf: walURL) == originalWAL)
    }
  }

  @Test("별도 모듈의 실제 SwiftData 파일에서 모든 필드와 날짜를 보존한다")
  func importsDiskStoreWithoutChangingSource() throws {
    let fixture = try makeFixture()
    defer { try? FileManager.default.removeItem(at: fixture.deletingLastPathComponent()) }
    let original = try Data(contentsOf: fixture)
    let walURL = URL(fileURLWithPath: fixture.path + "-wal")
    let originalWAL = try FileManager.default.fileExists(atPath: walURL.path)
      ? Data(contentsOf: walURL) : nil
    let database = try makeDatabase()

    try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: "manager")

    try database.read { (db: Database) throws in
      #expect(try #sql("SELECT userID FROM profileCache", as: Int.self).fetchOne(db) == 42)
      #expect(try #sql("SELECT name FROM profileCache", as: String.self).fetchOne(db) == "이전 사용자")
      #expect(try #sql("SELECT generation FROM profileCache", as: String.self).fetchOne(db) == "12기")
      #expect(try #sql("SELECT teamRawValue FROM profileCache", as: String.self).fetchOne(db) == "team-a")
      #expect(try #sql("SELECT jobRoleRawValue FROM profileCache", as: String.self).fetchOne(db) == "ios")
      #expect(try #sql("SELECT roleRawValue FROM profileCache", as: String.self).fetchOne(db) == "manager")
      #expect(try #sql("SELECT cachedAt FROM profileCache", as: Int64.self).fetchOne(db) == 1_780_000_000)
      let roles = try #require(try #sql("SELECT managerRolesData FROM profileCache", as: Data.self).fetchOne(db))
      #expect(try JSONDecoder().decode([String].self, from: roles) == ["photo", "unknown-role"])
      #expect(try #sql("SELECT id FROM scheduleCache", as: Int.self).fetchOne(db) == 7)
      #expect(try #sql("SELECT cachedAt FROM scheduleCache", as: Int64.self).fetchOne(db) == 1_780_000_001)
      #expect(try #sql("SELECT name FROM scheduleCache", as: String.self).fetchOne(db) == "정기 모임")
      #expect(try #sql("SELECT scheduleDescription FROM scheduleCache", as: String.self).fetchOne(db) == "이전 일정")
      #expect(try #sql("SELECT year * 10000 + month * 100 + day FROM scheduleCache", as: Int.self)
        .fetchOne(db) == 20_261_015)
      #expect(try markerCount(db) == 1)
      // 1.0.9의 역할만으로는 계정 소유권을 증명할 수 없다.
      #expect(try !LegacyCacheAccess.isAllowed(.profile, profileUserID: 42, in: db))
      #expect(try !LegacyCacheAccess.isAllowed(.schedule, in: db))
    }
    #expect(try Data(contentsOf: fixture) == original)
    #expect(FileManager.default.fileExists(atPath: walURL.path) == (originalWAL != nil))
    if let originalWAL {
      #expect(try Data(contentsOf: walURL) == originalWAL)
    }

    try setSession(42, in: database)
    try database.read { (db: Database) throws in
      #expect(try LegacyCacheAccess.isAllowed(.profile, profileUserID: 42, in: db))
      #expect(try !LegacyCacheAccess.isAllowed(.profile, profileUserID: 99, in: db))
      #expect(try LegacyCacheAccess.isAllowed(.schedule, in: db))
    }
    try setSession(99, in: database)
    try database.read { (db: Database) throws in
      #expect(try !LegacyCacheAccess.isAllowed(.profile, profileUserID: 42, in: db))
      #expect(try !LegacyCacheAccess.isAllowed(.schedule, in: db))
    }
    try database.write { db in
      try LegacyCacheAccess.markRefreshed(.profile, in: db)
      #expect(try LegacyCacheAccess.isAllowed(.profile, profileUserID: 99, in: db))
      #expect(try !LegacyCacheAccess.isAllowed(.schedule, in: db))
      try LegacyCacheAccess.markRefreshed(.schedule, in: db)
      #expect(try LegacyCacheAccess.isAllowed(.schedule, in: db))
    }
  }

  @Test("1.0.9의 단일 모델 저장소와 optional 값을 지원한다", arguments: [true, false])
  func importsSingleModelStore(profileOnly: Bool) throws {
    let fixture = try makeFixture(profile: profileOnly, schedule: !profileOnly, optionalValues: false)
    defer { try? FileManager.default.removeItem(at: fixture.deletingLastPathComponent()) }
    let database = try makeDatabase()
    try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: "manager")
    try database.read { (db: Database) throws in
      #expect(try profileCount(db) == (profileOnly ? 1 : 0))
      #expect(try scheduleCount(db) == (profileOnly ? 0 : 1))
      if profileOnly {
        #expect(try #sql(
          "SELECT COUNT(*) FROM profileCache WHERE teamRawValue IS NULL AND managerRolesData IS NULL",
          as: Int.self
        ).fetchOne(db) == 1)
      } else {
        // 일정만 있는 저장소는 소유자를 알 수 없어 네트워크 갱신 전까지 사용하지 않는다.
        #expect(try !LegacyCacheAccess.isAllowed(.schedule, in: db))
      }
    }
  }

  @Test("기존 SQLite 데이터셋을 덮어쓰거나 삭제된 일정을 복원하지 않는다")
  func preservesCurrentDatasets() throws {
    let fixture = try makeFixture()
    defer { try? FileManager.default.removeItem(at: fixture.deletingLastPathComponent()) }
    let database = try makeDatabase()
    try database.write { db in
      try #sql(
        "INSERT INTO profileCache VALUES ('profile.user.default', 123, 88, '현재 사용자', '13기', NULL, 'ios', 'member', NULL)"
      )
      .execute(db)
      try #sql("INSERT INTO scheduleCache VALUES (99, 456, '현재 일정', '', 1, 1, 2027)").execute(db)
    }
    try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: "manager")
    try database.read { (db: Database) throws in
      #expect(try profileCount(db) == 1)
      #expect(try #sql("SELECT userID FROM profileCache", as: Int.self).fetchOne(db) == 88)
      #expect(try scheduleCount(db) == 1)
      #expect(try #sql("SELECT id FROM scheduleCache", as: Int.self).fetchOne(db) == 99)
      #expect(try LegacyCacheAccess.isAllowed(.profile, in: db))
      #expect(try LegacyCacheAccess.isAllowed(.schedule, in: db))
    }
  }

  @Test("캐시 삭제 후 재실행해도 이전 데이터를 되살리지 않는다")
  func doesNotResurrectDeletedCache() throws {
    let fixture = try makeFixture()
    defer { try? FileManager.default.removeItem(at: fixture.deletingLastPathComponent()) }
    let database = try makeDatabase()
    try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: "manager")
    try database.write { db in
      try #sql("DELETE FROM profileCache").execute(db)
      try #sql("DELETE FROM scheduleCache").execute(db)
    }
    try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: "manager")
    try database.read { (db: Database) throws in
      #expect(try profileCount(db) == 0)
      #expect(try scheduleCount(db) == 0)
      #expect(try markerCount(db) == 1)
    }
  }

  @Test("현재 계정이 다르거나 로그아웃 상태면 복원하지 않는다", arguments: [true, false])
  func rejectsAnotherAccountOrLogout(differentAccount: Bool) throws {
    let fixture = try makeFixture()
    defer { try? FileManager.default.removeItem(at: fixture.deletingLastPathComponent()) }
    let database = try makeDatabase()
    if differentAccount {
      try setSession(99, in: database)
    } else {
      let data = Data(#"{"role":null}"#.utf8)
      try database.write { try #sql("INSERT INTO sharedValues VALUES ('staffRole', \(bind: data))").execute($0) }
    }
    try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: "manager")
    try database.read { (db: Database) throws in
      #expect(try profileCount(db) == 0)
      #expect(try scheduleCount(db) == 0)
      #expect(try markerCount(db) == 1)
    }
  }

  @Test("동일 계정이면 SQLite 전환 후에도 이전 캐시를 가져온다")
  func importsForMatchingCurrentAccount() throws {
    let fixture = try makeFixture()
    defer { try? FileManager.default.removeItem(at: fixture.deletingLastPathComponent()) }
    let database = try makeDatabase()
    try setSession(42, in: database)
    try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: nil)
    try database.read { (db: Database) throws in
      #expect(try profileCount(db) == 1)
      #expect(try scheduleCount(db) == 1)
      #expect(try LegacyCacheAccess.isAllowed(.profile, profileUserID: 42, in: db))
    }
  }

  @Test("대상 쓰기 실패 시 캐시와 완료 표시를 함께 롤백한다")
  func rollsBackFailedImport() throws {
    let fixture = try makeFixture()
    defer { try? FileManager.default.removeItem(at: fixture.deletingLastPathComponent()) }
    let database = try makeDatabase()
    try database.write { db in
      try #sql(
        "CREATE TRIGGER rejectSchedule BEFORE INSERT ON scheduleCache BEGIN SELECT RAISE(ABORT, 'test failure'); END"
      )
      .execute(db)
    }
    #expect(throws: (any Error).self) {
      try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: "manager")
    }
    try database.read { (db: Database) throws in
      #expect(try profileCount(db) == 0)
      #expect(try markerCount(db) == 0)
    }
    try database.write { try #sql("DROP TRIGGER rejectSchedule").execute($0) }
    try LegacySwiftDataMigration.migrate(into: database, sourceURL: fixture, legacyRole: "manager")
    try database.read { (db: Database) throws in
      #expect(try profileCount(db) == 1)
      #expect(try scheduleCount(db) == 1)
      #expect(try markerCount(db) == 1)
    }
  }

  @Test("파일이 없으면 완료 처리하고 손상 파일이면 재시도 가능하게 남긴다")
  func missingAndCorruptSource() throws {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: url) }
    let missingDatabase = try makeDatabase()
    try LegacySwiftDataMigration.migrate(into: missingDatabase, sourceURL: url, legacyRole: "manager")
    #expect(try missingDatabase.read { try markerCount($0) } == 1)
    try Data("invalid sqlite".utf8).write(to: url)
    let corruptDatabase = try makeDatabase()
    #expect(throws: (any Error).self) {
      try LegacySwiftDataMigration.migrate(into: corruptDatabase, sourceURL: url, legacyRole: "manager")
    }
    #expect(try corruptDatabase.read { try markerCount($0) } == 0)
  }

  private func makeDatabase() throws -> DatabaseQueue {
    let database = try DatabaseQueue()
    try AppDatabaseMigrator.migrate(database)
    return database
  }

  private func setSession(_ userID: Int, in database: DatabaseQueue) throws {
    let data = try JSONEncoder().encode(["userID": userID])
    try database
      .write { try #sql("INSERT OR REPLACE INTO sharedValues VALUES ('UserSession', \(bind: data))").execute($0) }
  }

  private func profileCount(_ db: Database) throws -> Int? {
    try #sql("SELECT COUNT(*) FROM profileCache", as: Int.self).fetchOne(db)
  }

  private func scheduleCount(_ db: Database) throws -> Int? {
    try #sql("SELECT COUNT(*) FROM scheduleCache", as: Int.self).fetchOne(db)
  }

  private func markerCount(_ db: Database) throws -> Int? {
    try #sql("SELECT COUNT(*) FROM legacyCacheImport", as: Int.self).fetchOne(db)
  }

  private func makeFixture(
    profile: Bool = true, schedule: Bool = true, optionalValues: Bool = true
  ) throws -> URL {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let url = directory.appendingPathComponent("default.store")
    let writerDirectory = directory.appendingPathComponent("writer", isDirectory: true)
    try FileManager.default.createDirectory(at: writerDirectory, withIntermediateDirectories: true)
    let writerURL = writerDirectory.appendingPathComponent("default.store")
    try autoreleasepool {
      var models: [any PersistentModel.Type] = []
      if profile {
        models.append(ProfileCacheEntity.self)
      }
      if schedule {
        models.append(ScheduleCacheEntity.self)
      }
      let schema = Schema(models)
      let configuration = ModelConfiguration(schema: schema, url: writerURL, cloudKitDatabase: .none)
      let container = try ModelContainer(for: schema, configurations: [configuration])
      let context = ModelContext(container)
      context.autosaveEnabled = false
      if profile {
        context.insert(ProfileCacheEntity(
          cacheKey: "profile.user.default", cachedAt: Date(timeIntervalSince1970: 1_780_000_000),
          userID: 42, name: "이전 사용자", generation: "12기", teamRawValue: optionalValues ? "team-a" : nil,
          jobRoleRawValue: "ios", roleRawValue: "manager",
          managerRolesRawValues: optionalValues ? ["photo", "unknown-role"] : nil
        ))
      }
      if schedule {
        context.insert(ScheduleCacheEntity(
          id: 7, cachedAt: Date(timeIntervalSince1970: 1_780_000_001), name: "정기 모임",
          scheduleDescription: "이전 일정", month: 10, day: 15, year: 2026
        ))
      }
      try context.save()
      // 컨테이너 종료 시 checkpoint가 비교 대상 파일을 바꾸지 않도록,
      // writer가 살아 있는 동안 DB와 WAL을 별도의 열지 않은 fixture로 복사한다.
      try withExtendedLifetime((container, context)) {
        try FileManager.default.copyItem(at: writerURL, to: url)
        let writerWAL = URL(fileURLWithPath: writerURL.path + "-wal")
        if FileManager.default.fileExists(atPath: writerWAL.path) {
          try FileManager.default.copyItem(at: writerWAL, to: URL(fileURLWithPath: url.path + "-wal"))
        }
      }
    }
    return url
  }
}
