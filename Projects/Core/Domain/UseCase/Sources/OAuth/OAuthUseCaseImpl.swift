//
//  OAuthUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import AuthenticationServices

import DomainInterface
import DiContainer
import Model
import Repository

import ComposableArchitecture

public struct OAuthUseCaseImpl: OAuthInterface {
  private let repository: OAuthInterface

  public init(
    repository: OAuthInterface
  ) {
    self.repository = repository
  }

  // MARK: - 애플 일반 로그인

  public func handleAppleLogin(
    _ requestResult: Result<ASAuthorization, any Error>,
    nonce: String) async throws -> ASAuthorization {
      try await repository
        .handleAppleLogin(
          requestResult,
          nonce: nonce
        )
    }

  // MARK: - firebase 애플 로그인

  public func appleLoginWithFireBase(
    withIDToken: String ,
    rawNonce: String,
    fullName: ASAuthorizationAppleIDCredential
  ) async throws -> OAuthResponseModel? {
    try await repository.appleLoginWithFireBase(
      withIDToken: withIDToken,
      rawNonce: rawNonce,
      fullName: fullName
    )
  }

  // MARK: - 구글 로그인

  public func googleLogin() async throws -> OAuthResponseModel? {
    try await repository.googleLogin()
  }
}

extension DependencyContainer {
  var oAuthUseCase: OAuthInterface? {
    resolve(OAuthInterface.self)
  }
}

extension OAuthUseCaseImpl: DependencyKey {
  static public var liveValue: OAuthInterface =  {
    let repository =  ContainerResgister(\.oAuthUseCase).wrappedValue
    return OAuthUseCaseImpl(repository: repository)
  }()
}

public extension DependencyValues {
  var oAuthUseCase: OAuthInterface {
    get { self[OAuthUseCaseImpl.self] }
    set { self[OAuthUseCaseImpl.self] = newValue }
  }
}


public extension RegisterModule {

  var oAuthUseCaseImplModule: () -> Module {
    makeUseCaseWithRepository(
      OAuthInterface.self,
      repositoryProtocol: OAuthInterface.self,
      repositoryFallback: DefaultOAuthRepositoryImpl(),
      factory: { repo in
        OAuthUseCaseImpl(repository: repo)
      }
    )
  }

  var oAuthRepositoryImplModule: () -> Module {
    makeDependency(OAuthInterface.self) {
      OAuthRepositoryImpl()
    }
  }
}

