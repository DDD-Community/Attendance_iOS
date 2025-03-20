//
//  AppDIContainer.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/8/24.
//

import Foundation

import DiContainer
import UseCase

extension AppDIContainer {
  public func registerDefaultDependencies() async {
    await registerDependencies { container in
      var repositoryFactory = RepositoryModuleFactory()
      let useCaseFactory = UseCaseModuleFactory()
      repositoryFactory.registerDefaultDefinitions()
      
      repositoryFactory.makeAllModules().forEach {
        container.register($0)
      }
      useCaseFactory.makeAllModules().forEach {
        container.register($0)
      }
    }
  }
}
