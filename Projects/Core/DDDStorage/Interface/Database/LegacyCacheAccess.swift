import Foundation
import SQLiteData

/// 이전 캐시의 소유자가 확인되기 전에는 화면에 노출하지 않는다.
public enum LegacyCacheAccess {
  public enum Cache { case profile, schedule }

  public static func isAllowed(_ cache: Cache, profileUserID: Int? = nil, in db: Database) throws -> Bool {
    let owner: Int?
    switch cache {
    case .profile:
      owner = try #sql(
        "SELECT profileUserID FROM legacyCacheImport WHERE id = 1 AND profileUserID IS NOT NULL",
        as: Int.self
      ).fetchOne(db)
    case .schedule:
      owner = try #sql(
        "SELECT scheduleUserID FROM legacyCacheImport WHERE id = 1 AND scheduleUserID IS NOT NULL",
        as: Int.self
      ).fetchOne(db)
    }
    guard let owner else { return true }
    if let profileUserID, owner != profileUserID {
      return false
    }
    guard owner > 0,
          let data = try #sql("SELECT value FROM sharedValues WHERE key = 'UserSession'", as: Data.self).fetchOne(db),
          let session = try? JSONDecoder().decode(SessionIdentity.self, from: data)
    else { return false }
    return owner == session.userID
  }

  public static func markRefreshed(_ cache: Cache, in db: Database) throws {
    switch cache {
    case .profile:
      try #sql("UPDATE legacyCacheImport SET profileUserID = NULL WHERE id = 1").execute(db)
    case .schedule:
      try #sql("UPDATE legacyCacheImport SET scheduleUserID = NULL WHERE id = 1").execute(db)
    }
  }

  private struct SessionIdentity: Decodable { let userID: Int }
}
