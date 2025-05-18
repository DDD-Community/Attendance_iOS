//
//  DefaultProfileRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/8/25.
//

import Combine

import Model


public final class DefaultProfileRepository: ProfileRepositoryProtocol {
  
  public init() {}
  
  
  public func editProfile(
    name: String,
    inviteCode: String,
    role: String,
    crew: String,
    responsibility: String
  ) async throws -> ProfileDTOModel? {
    return nil
  }
  
  public func getProfile() async throws -> ProfileDTOModel? {
    return nil
  }
}

