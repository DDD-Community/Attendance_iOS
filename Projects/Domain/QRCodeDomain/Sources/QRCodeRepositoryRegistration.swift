import Dependencies
import QRCodeDomainInterface

public extension DependencyValues {
  mutating func registerQRCodeRepository() {
    qrCodeRepository = resolve { QRCodeRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
