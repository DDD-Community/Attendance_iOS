//
//  ProfileUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/8/25.
//

import DiContainer
import Model

import ComposableArchitecture

public struct ProfileUseCase: ProfileUseCaseProtocol {
  private let repository: ProfileRepositoryProtocol
  
  public init(
    repository: ProfileRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  // MARK: - 프로필 수정
  public func editProfile(
    name: String,
    inviteCode: String,
    role: String,
    team: String
  ) async throws -> ProfileDTOModel? {
    return try await repository.editProfile(
      name: name,
      inviteCode: inviteCode,
      role: role,
      team: team
    )
  }
  
  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileDTOModel? {
    return try await repository.getProfile()
  }
}


extension DependencyContainer {
  var profileUseCase: ProfileRepositoryProtocol? {
    resolve(ProfileRepositoryProtocol.self)
  }
}


extension ProfileUseCase: DependencyKey {
  static public var liveValue: ProfileUseCase = {
    let profileRepository = ContainerResgister(\.profileUseCase).wrappedValue
    return ProfileUseCase(repository: profileRepository)
  }()
}

public extension DependencyValues {
  var profileUseCase: ProfileUseCase {
    get { self[ProfileUseCase.self] }
    set { self[ProfileUseCase.self] = newValue }
  }
}

public extension RegisterModule {
  
  var profileUseCaseModule: () -> Module {
    makeUseCaseWithRepository(
      ProfileUseCaseProtocol.self,
      repositoryProtocol: ProfileRepositoryProtocol.self,
      repositoryFallback: DefaultProfileRepository(),
      factory: { repo in
        ProfileUseCase(repository: repo)
      }
    )
  }
  
  var profileRepositoryModule: () -> Module {
    makeDependency(ProfileRepositoryProtocol.self) {
      ProfileRepository()
    }
  }
  
}
