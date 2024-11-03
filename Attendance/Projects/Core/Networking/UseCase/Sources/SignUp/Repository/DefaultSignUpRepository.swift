//
//  DefaultSignUpRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Model

final public class DefaultSignUpRepository: SignUpRepositoryProtcol {
  public init() {
    
  }
  
  public func validateInviteCode(
    code: String
  ) async throws -> InviteDTOModel? {
    return nil
  }
  
}
