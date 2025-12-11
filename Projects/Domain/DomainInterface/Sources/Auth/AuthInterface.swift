//
//  AuthInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation

public protocol AuthInterface: Sendable {
  func loginUser(email: String) async throws -> LoginModel?
}
