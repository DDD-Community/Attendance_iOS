import AuthDomainInterface
import Dependencies

public extension DependencyValues {
  mutating func registerAuthRepositories() {
    authRepository = resolve { AuthRepositoryImpl() }
    googleOAuthRepository = resolve { GoogleOAuthRepositoryImpl() }
    appleManger = resolve { AppleLoginRepositoryImpl() }
    appleOAuthRepository = resolve { AppleOAuthRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
