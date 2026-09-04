//
//  SignUpRepositoryImpl.swift
//  OnBoardingDomain
//
//  Created by DDD on 7/23/25.
//

import Combine

import DDDNetworkInterface
import Dependencies
import OnBoardingDomainInterface
import APIEndpoint

final public class SignUpRepositoryImpl: SignUpInterface {


  @Dependency(\.networkClient) private var client

  public init() {}

  // Mark : -  API 회원가입
  public func registerUser(
    input: SignUpUserInput
  ) async throws(SignUpError) -> SignUpUser {
    do {
      // SignUpUserInput을 SignUpUserRequestDTO로 변환
      let body = input.toRequestDTO()
      let dto = try await client.send(
        SignUpService.signUpUser(body: body),
        as: SignUpUserDTO.self
      )
      return dto.toDomain()
    } catch {
      throw .accountCreationFailed
    }
  }
}
