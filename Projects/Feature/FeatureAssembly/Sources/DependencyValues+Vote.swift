//
//  DependencyValues+Vote.swift
//  FeatureAssembly
//
//  Created by DDD on 9/2/26.
//

import Dependencies
import DomainInterface

extension VoteRepositoryDependency: DependencyKey {
  public static var liveValue: VoteInterface {
    return RepositoryFactory.vote
  }
}
