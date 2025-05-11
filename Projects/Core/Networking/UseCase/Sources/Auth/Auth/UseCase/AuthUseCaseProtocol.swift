//
//  AuthUseCaseProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import Model

public protocol AuthUseCaseProtocol {
  func fetchUser(uid: String) async throws -> UserDTOMember?
}
