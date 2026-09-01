//
//  DependencyValues+Vote.swift
//  FeatureAssembly
//
//  투표 구현 등록.
//  인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 붙이는 조립 지점.
//

import Dependencies
import DomainInterface

extension VoteRepositoryDependency: DependencyKey {
  public static var liveValue: VoteInterface {
    return RepositoryFactory.vote
  }
}
