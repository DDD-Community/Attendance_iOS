//
//  DependencyValues+OnBoarding.swift
//  FeatureAssembly
//
//  온보딩·회원가입 구현 등록.
//  인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 붙이는 조립 지점.
//

import Dependencies
import DomainInterface

import Repository

extension OnBoardingRepositoryDependency: DependencyKey {
  public static var liveValue: OnBoardingInterface { OnBoardingRepositoryImpl() }
}

extension SignUpRepositoryDependency: DependencyKey {
  public static var liveValue: SignUpInterface { SignUpRepositoryImpl() }
}
