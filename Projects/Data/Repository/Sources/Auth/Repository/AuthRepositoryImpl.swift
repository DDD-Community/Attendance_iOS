//
//  AuthRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Entity

import Service

@preconcurrency import AsyncMoya
import FirebaseFirestore


@Observable
final public class AuthRepositoryImpl: AuthInterface, Sendable {

  
  private let provider: MoyaProvider<AuthService>

  public init(
    provider: MoyaProvider<AuthService> = MoyaProvider<AuthService>.default
  ) {
    self.provider = provider
  }


  // MARK: - 회원가입한 유저 조회

  // MARK: - 로그인 API
  public func login(
    provider socialProvider: SocialType,
    token: String
  ) async throws -> LoginEntity {
    let dto: LoginResponseDTO = try await provider.request(
      .login(body: OAuthLoginRequest(provider: socialProvider.description, token: token))
     )
    return dto.toDomain()
  }
}
