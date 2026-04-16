//
//  SignUpRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import Combine

import DomainInterface
import Model
import Entity
import Service

@preconcurrency import AsyncMoya

@Observable
final public class SignUpRepositoryImpl: SignUpInterface {


  private let provider: MoyaProvider<SignUpService>

  public init(
    provider: MoyaProvider<SignUpService> = MoyaProvider<SignUpService>.default
  ) {
    self.provider = provider
  }

  // Mark : -  API 회원가입
  public func registerUser(
    input: SignUpUserInput
  ) async throws -> SignUpUser {
    // SignUpUserInput을 SignUpUserRequestDTO로 변환
    let body = input.toRequestDTO()
    let dto: SignUpUserDTO = try await provider.request(.signUpUser(body: body))
    return dto.toDomain()
  }
}
