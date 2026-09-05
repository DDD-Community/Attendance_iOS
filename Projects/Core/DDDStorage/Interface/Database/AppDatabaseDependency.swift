import Dependencies
import SQLiteData

public enum AppDatabaseDependency: TestDependencyKey {
  public static var testValue: any DatabaseWriter {
    try! SQLiteData.defaultDatabase()
  }
}

public extension DependencyValues {
  var appDatabase: any DatabaseWriter {
    get { self[AppDatabaseDependency.self] }
    set { self[AppDatabaseDependency.self] = newValue }
  }
}
