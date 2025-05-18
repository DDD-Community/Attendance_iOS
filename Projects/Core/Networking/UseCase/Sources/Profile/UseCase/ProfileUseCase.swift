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
  public func editProfileManger(
    name: String,
    inviteCode: String,
    role: String,
    crew: String,
    responsibility: String
  ) async throws -> ProfileResponseModel? {
    return try await repository.editProfileManger(
      name: name,
      inviteCode: inviteCode,
      role: role,
      crew: crew,
      responsibility: responsibility
    )
  }
  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileResponseModel? {
    return try await repository.getProfile()
  }
  
  // MARK: - 프로필수정 운영진 팀 없을때
  public func editProfileMangerNoTeam(
    name: String,
    inviteCode: String,
    role: String,
    responsibility: String
  ) async throws -> ProfileDTOModel? {
    return try await repository.editProfileMangerNoTeam(
      name: name,
      inviteCode: inviteCode,
      role: role,
      responsibility: responsibility
    )
  }
  
  // MARK: - 프로필 수정 멤법
  public func editProfileMember(
    name: String,
    inviteCode: String,
    role: String,
    crew: String
  ) async throws -> ProfileDTOModel? {
    return try await repository.editProfileMember(
      name: name,
      inviteCode: inviteCode,
      role: role,
      crew: crew
    )
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
