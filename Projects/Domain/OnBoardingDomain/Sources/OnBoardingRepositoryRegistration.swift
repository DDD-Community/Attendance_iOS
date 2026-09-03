import Dependencies
import OnBoardingDomainInterface

public extension DependencyValues {
  mutating func registerOnBoardingRepositories() {
    onBoardingRepository = resolve { OnBoardingRepositoryImpl() }
    signUpRepository = resolve { SignUpRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
