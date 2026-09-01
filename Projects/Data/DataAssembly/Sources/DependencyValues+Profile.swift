//
//  DependencyValues+Profile.swift
//  FeatureAssembly
//
//  프로필·마이페이지·앱업데이트 구현 등록.
//  인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 붙이는 조립 지점.
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
