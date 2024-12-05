//
//  AppDIContainer.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/8/24.
//

import Foundation
import DiContainer
import UseCase

public final class AppDIContainer {
  public static let shared: AppDIContainer = .init()
  
  private init() {}
  
  public func registerDependencies() async {
    let container = Container() // Container 초기화
    let useCaseModuleFactory = UseCaseModuleFactory() // 팩토리 인스턴스 생성
    let repositoryModuleFactory = RepositoryModuleFactory()
    
    await container {
      repositoryModuleFactory.makeAllModules().forEach { module in
        container.register(module)
      }
      useCaseModuleFactory.makeAllModules().forEach { module in
        container.register(module)
      }
    }.build() // 등록된 모든 의존성을 처리
  }
}
