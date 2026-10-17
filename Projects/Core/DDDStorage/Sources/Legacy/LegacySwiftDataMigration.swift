import CoreData
import Foundation
import SQLiteData
import SwiftData

enum LegacySwiftDataMigration {
  enum ImportError: Error {
    case unsupportedSchema
  }

  static func migrate(
    into database: any DatabaseWriter,
    sourceURL: URL = ModelConfiguration(isStoredInMemoryOnly: false).url,
    legacyRole: String? = UserDefaults.standard.string(forKey: "staffRole")
  ) throws {
    guard try !database.read({ try isComplete($0) }) else { return }

    guard FileManager.default.fileExists(atPath: sourceURL.path) else {
      try database.write { try markComplete($0) }
      return
    }

    // CoreData는 읽기 전용으로 열어도 WAL checkpoint 등으로 원본 파일을 바꿀 수 있다.
    // 이전 SwiftData 컨테이너를 사용하지 않는 앱 초기화 시점에 DB와 WAL을 복사해 읽는다.
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("legacy-cache-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let snapshotURL = directory.appendingPathComponent(sourceURL.lastPathComponent)
    try FileManager.default.copyItem(at: sourceURL, to: snapshotURL)
    let walURL = URL(fileURLWithPath: sourceURL.path + "-wal")
    if FileManager.default.fileExists(atPath: walURL.path) {
      try FileManager.default.copyItem(at: walURL, to: URL(fileURLWithPath: snapshotURL.path + "-wal"))
    }

    let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
      ofType: NSSQLiteStoreType,
      at: snapshotURL,
      options: [NSReadOnlyPersistentStoreOption: true]
    )
    guard let hashes = metadata[NSStoreModelVersionHashesKey] as? [String: Data],
          !hashes.isEmpty,
          Set(hashes.keys).isSubset(of: ["ProfileCacheEntity", "ScheduleCacheEntity"])
    else { throw ImportError.unsupportedSchema }

    var models: [any PersistentModel.Type] = []
    if hashes["ProfileCacheEntity"] != nil {
      models.append(ProfileCacheEntity.self)
    }
    if hashes["ScheduleCacheEntity"] != nil {
      models.append(ScheduleCacheEntity.self)
    }
    let schema = Schema(models)
    let configuration = ModelConfiguration(
      schema: schema, url: snapshotURL, allowsSave: false, cloudKitDatabase: .none
    )
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let context = ModelContext(container)
    context.autosaveEnabled = false
    let profiles = hashes["ProfileCacheEntity"] == nil
      ? [] : try context.fetch(FetchDescriptor<ProfileCacheEntity>())
    let schedules = hashes["ScheduleCacheEntity"] == nil
      ? [] : try context.fetch(FetchDescriptor<ScheduleCacheEntity>())
    let profile = profiles.first { $0.cacheKey == "profile.user.default" }

    try database.write { db in
      guard try !isComplete(db) else { return }
      var profileOwner: Int?
      var scheduleOwner: Int?
      if try canImport(profile: profile, legacyRole: legacyRole, db: db) {
        // 현재 테이블 전체를 보존한다. 일정 일부만 채우면 삭제된 일정이 되살아날 수 있다.
        if let profile,
           try #sql("SELECT COUNT(*) FROM profileCache", as: Int.self).fetchOne(db) == 0
        {
          profileOwner = profile.userID
          let roles = try profile.managerRolesRawValues.map { try JSONEncoder().encode($0) }
          let timestamp = Int64(profile.cachedAt.timeIntervalSince1970)
          try #sql("""
          INSERT INTO profileCache
            (cacheKey, cachedAt, userID, name, generation, teamRawValue,
             jobRoleRawValue, roleRawValue, managerRolesData)
          VALUES (\(bind: profile.cacheKey), \(bind: timestamp), \(bind: profile.userID),
            \(bind: profile.name), \(bind: profile.generation), \(bind: profile.teamRawValue),
            \(bind: profile.jobRoleRawValue), \(bind: profile.roleRawValue), \(bind: roles))
          """).execute(db)
        }
        if try #sql("SELECT COUNT(*) FROM scheduleCache", as: Int.self).fetchOne(db) == 0 {
          if !schedules.isEmpty {
            scheduleOwner = profile?.userID ?? 0
          }
          for schedule in schedules {
            let timestamp = Int64(schedule.cachedAt.timeIntervalSince1970)
            try #sql("""
            INSERT INTO scheduleCache (id, cachedAt, name, scheduleDescription, month, day, year)
            VALUES (\(bind: schedule.id), \(bind: timestamp), \(bind: schedule.name),
              \(bind: schedule.scheduleDescription), \(bind: schedule.month),
              \(bind: schedule.day), \(bind: schedule.year))
            """).execute(db)
          }
        }
      }
      try markComplete(db, profileOwner: profileOwner, scheduleOwner: scheduleOwner)
    }
  }

  private static func canImport(
    profile: ProfileCacheEntity?, legacyRole: String?, db: Database
  ) throws -> Bool {
    // 이미 SQLite로 전환한 사용자는 현재 계정과 일치할 때만 복원한다.
    let sessionData = try #sql("SELECT value FROM sharedValues WHERE key = 'UserSession'", as: Data.self)
      .fetchOne(db)
    let roleData = try #sql("SELECT value FROM sharedValues WHERE key = 'staffRole'", as: Data.self)
      .fetchOne(db)
    if let roleData {
      let role = try JSONDecoder().decode(RoleSnapshot.self, from: roleData).role
      guard role == "member" || role == "manager" else { return false }
    }
    if let sessionData {
      let userID = try JSONDecoder().decode(SessionIdentity.self, from: sessionData).userID
      return userID > 0 && userID == profile?.userID
    }
    // 1.0.9의 세션은 메모리 전용이며 로그인 역할만 UserDefaults에 남는다.
    // 현재 역할만 남고 세션이 없는 상태는 소유자를 확인할 수 없어 복원하지 않는다.
    guard roleData == nil, legacyRole == "member" || legacyRole == "manager" else { return false }
    return profile == nil || profile?.roleRawValue == legacyRole
  }

  private static func isComplete(_ db: Database) throws -> Bool {
    try #sql("SELECT COUNT(*) FROM legacyCacheImport WHERE id = 1", as: Int.self).fetchOne(db) == 1
  }

  private static func markComplete(
    _ db: Database, profileOwner: Int? = nil, scheduleOwner: Int? = nil
  ) throws {
    try #sql("""
    INSERT OR IGNORE INTO legacyCacheImport (id, profileUserID, scheduleUserID)
    VALUES (1, \(bind: profileOwner), \(bind: scheduleOwner))
    """).execute(db)
  }

  private struct SessionIdentity: Decodable { let userID: Int }
  private struct RoleSnapshot: Decodable { let role: String? }
}
