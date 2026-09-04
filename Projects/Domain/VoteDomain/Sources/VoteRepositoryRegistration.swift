import Dependencies
import VoteDomainInterface

public extension DependencyValues {
  mutating func registerVoteRepository() {
    voteRepository = resolve { VoteRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
