//
//  SignUpRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import Combine

import DDDNetworkInterface
import DomainInterface
import Model
import Entity
import APIEndpoint

final public class SignUpRepositoryImpl: SignUpInterface {


  private let client: any DDDNetworkClient

  public init(
    client: any DDDNetworkClient
  ) {
    self.client = client
  }

  // Mark : -  API 회원가입
  public func registerUser(
    input: SignUpUserInput
  ) async throws -> SignUpUser {
    // SignUpUserInput을 SignUpUserRequestDTO로 변환
    let body = input.toRequestDTO()
    let dto = try await client.send(
      SignUpService.signUpUser(body: body),
      as: SignUpUserDTO.self
    )
    return dto.toDomain()
  }
}
