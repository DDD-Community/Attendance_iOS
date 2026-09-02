//
//  DependencyValues+OnBoarding.swift
//  FeatureAssembly
//
//  Created by DDD on 9/2/26.
//

import Dependencies
import DomainInterface

extension OnBoardingRepositoryDependency: DependencyKey {
  public static var liveValue: OnBoardingInterface {
    return RepositoryFactory.onBoarding
  }
}

extension SignUpRepositoryDependency: DependencyKey {
  public static var liveValue: SignUpInterface {
    return RepositoryFactory.signUp
  }
}
