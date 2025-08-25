//
//  DefaultAuthRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

final public class DefaultAuthRepositoryImpl: AuthInterface {

  public init() {}

  public func fetchUser(uid: String) async throws -> UserDTOMember? {
    return nil
  }

  public func loginUser(
    email: String
  ) async throws -> LoginModel? {
    return nil
  }
}
