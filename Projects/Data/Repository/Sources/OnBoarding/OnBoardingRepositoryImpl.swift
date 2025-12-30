//
//  OnBoardingRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation

import DomainInterface
import Service
import Entity

@preconcurrency  import AsyncMoya

final public class OnBoardingRepositoryImpl:OnBoardingInterface {
  private let provider: MoyaProvider<OnBoardingService>

  public init(
    provider: MoyaProvider<OnBoardingService> = MoyaProvider<OnBoardingService>.default
  ) {
    self.provider = provider
  }

  public func verifyCode(
    code: String
  ) async throws -> VerifyCodeEntity {
    let dto: VerifyCodeDTO = try await provider.request(.verifyCode(code: code))
    return dto.toDomain()
  }
}
