//
//  DependencyValues+Profile.swift
//  FeatureAssembly
//
//  Created by DDD on 9/2/26.
//

import Dependencies
import DomainInterface

extension ProfileRepositoryDependency: DependencyKey {
  public static var liveValue: ProfileInterface {
    return RepositoryFactory.profile
  }
}

extension MyPageRepositoryDependency: DependencyKey {
  public static var liveValue: any MyPageRepositoryInterface {
    return RepositoryFactory.myPage
  }
}

extension AppUpdateRepositoryDependency: DependencyKey {
  public static var liveValue: AppUpdateInterface {
    return RepositoryFactory.appUpdate
  }
}
