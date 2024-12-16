//
//  DefaultAuthRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import Model

final public class DefaultAuthRepository: AuthRepositoryProtocol {
  
  public init() {}
  
  public func fetchUser(uid: String) async throws -> UserDTOMember? {
    return nil
  }
}
