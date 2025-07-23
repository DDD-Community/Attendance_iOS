//
//  AuthRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import Model

public protocol AuthRepositoryProtocol {
  func loginUser(email: String) async throws -> LoginModel?
}
