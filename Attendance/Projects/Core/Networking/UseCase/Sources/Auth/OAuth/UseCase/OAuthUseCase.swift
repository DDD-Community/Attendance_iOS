//
//  OAuthUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 10/30/24.
//

import AuthenticationServices

import DiContainer
import Model

import ComposableArchitecture

public struct OAuthUseCase: OAuthUseCaseProtocol {
  private let repository: OAuthRepositoryProtocol
  
  public init(
    repository: OAuthRepositoryProtocol
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
  ) async throws -> OAuthResponseDTOModel? {
    try await repository.appleLoginWithFireBase(
      withIDToken: withIDToken,
      rawNonce: rawNonce,
      fullName: fullName
    )
  }
  
  // MARK: - 구글 로그인
  
  public func googleLogin() async throws -> OAuthResponseDTOModel? {
    try await repository.googleLogin()
  }
}

extension DependencyContainer {
  var oAuthUseCase: OAuthRepositoryProtocol? {
    resolve(OAuthRepositoryProtocol.self)
  }
}

extension OAuthUseCase: DependencyKey {
  static public var liveValue: OAuthUseCase =  {
    let oAuthRepository =  ContainerResgister(\.oAuthUseCase).wrappedValue
    return OAuthUseCase(repository: oAuthRepository)
  }()
}

public extension DependencyValues {
  var oAuthUseCase: OAuthUseCase {
    get { self[OAuthUseCase.self] }
    set { self[OAuthUseCase.self] = newValue }
  }
}


public extension RegisterModule {
  
  var oAuthUseCaseModule: () -> Module {
    makeUseCaseWithRepository(
      OAuthUseCaseProtocol.self,
      repositoryProtocol: OAuthRepositoryProtocol.self,
      repositoryFallback: DefaultOAuthRepository(),
      factory: { repo in
        OAuthUseCase(repository: repo)
      }
    )
  }
  
  var oAuthRepositoryModule: () -> Module {
    makeDependency(OAuthRepositoryProtocol.self) {
      OAuthRepository()
    }
  }
}
