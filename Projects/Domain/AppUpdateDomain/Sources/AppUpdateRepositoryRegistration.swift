import AppUpdateDomainInterface
import Dependencies

public extension DependencyValues {
  mutating func registerAppUpdateRepository() {
    appUpdateRepository = resolve { AppUpdateRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
