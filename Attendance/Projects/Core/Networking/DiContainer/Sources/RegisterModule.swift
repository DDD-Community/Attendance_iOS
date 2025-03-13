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
  
  /// 통합 모듈 생성 함수: Repository와 UseCase 모두 이 함수를 통해 생성하며, kind에 따라 추가 구성이 가능함.
  public func makeModule<T, U>(
    _ protocolType: T.Type,
    kind: ModuleKind,
    factory: @escaping () -> U
  ) -> () -> Module {
    return {
      guard let instance = factory() as? T else {
        fatalError("Failed to cast \(U.self) to \(T.self)")
      }
      // 기본 모듈 생성
      var module = self.makeModule(protocolType, factory: { instance })
      
      // ModuleKind에 따른 추가 구성(필요 시)
      #if DEBUG
      #logDebug("Module created for \(protocolType) as \(kind)")
      #endif
      
      return module
    }
  }
  
  // MARK: - Repository 생성 (기존 API와의 호환성을 위한 래퍼)
  public func makeRepository<T, U>(
    _ protocolType: T.Type,
    factory: @escaping () -> U
  ) -> () -> Module {
    return makeModule(protocolType, kind: .repository, factory: factory)
  }
  
  // MARK: - UseCase 생성 (기존 API와의 호환성을 위한 래퍼)
  public func makeUseCase<T, U>(
    _ protocolType: T.Type,
    factory: @escaping () -> U
  ) -> () -> Module {
    return makeModule(protocolType, kind: .useCase, factory: factory)
  }
  
  // MARK: -  di에 등록
  public func resolveOrDefault<T>(
    _ type: T.Type,
    default defaultFactory: @autoclosure @escaping () -> T
  ) -> T {
    DependencyContainer.live.resolveOrDefault(type, default: defaultFactory())
  }
}
