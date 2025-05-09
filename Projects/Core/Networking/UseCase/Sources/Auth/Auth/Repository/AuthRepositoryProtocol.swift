//
//  AuthRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import Model

public protocol AuthRepositoryProtocol {
  func fetchUser(uid: String) async throws -> UserDTOMember?
  func loginUser(email: String, password: String) async throws -> LoginDTOModel?
  func sessionCheckJWT(token: String) async throws -> LoginDTOModel?
}
