//
//  RegisterModule.swift
//  DiContainer
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation
import AsyncMoya

public struct RegisterModule {
  public init() {}

  public func makeModule<T>(_ type: T.Type, factory: @escaping () -> T) -> Module {
    Module(type, factory: factory)
  }
  
  // MARK: - Repository/UseCase 공통 모듈 생성
  private func makeDependencyModule<T>(
    _ type: T.Type,
    factory: @escaping () -> T
  ) -> Module {
    self.makeModule(type, factory: factory)
  }
  
  // MARK: - Repository 생성 (기존 API와의 호환성을 위한 래퍼)
  public func makeRepository<T, U>(
    _ protocolType: T.Type,
    factory: @escaping () -> U
  ) -> () -> Module {
    return {
      self.makeDependencyModule(protocolType) {
        guard let repository = factory() as? T else {
          fatalError("Failed to cast \(U.self) to \(T.self)")
        }
        return repository
      }
    }
  }
  
  // MARK: - UseCase 생성 (기존 API와의 호환성을 위한 래퍼)
  public func makeUseCase<T, U>(
    _ protocolType: T.Type,
    factory: @escaping () -> U
  ) -> () -> Module {
    return {
      self.makeDependencyModule(protocolType) {
        guard let useCase = factory() as? T else {
          fatalError("Failed to cast \(U.self) to \(T.self)")
        }
        return useCase
      }
    }
  }
  
  // MARK: - di에 등록
  public func resolveOrDefault<T>(
    _ type: T.Type,
    default defaultFactory: @autoclosure @escaping () -> T
  ) -> T {
    DependencyContainer.live.resolveOrDefault(type, default: defaultFactory())
  }
}
