import Dependencies
import MyPageDomainInterface

public extension DependencyValues {
  mutating func registerMyPageRepository() {
    myPageRepository = resolve { MyPageRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
