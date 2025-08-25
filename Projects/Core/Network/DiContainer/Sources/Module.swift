//
//  Module.swift
//  DiContainer
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

/// Module은 의존성 등록 과정을 캡슐화하는 구조체입니다.
/// 각 Module 인스턴스는 특정 타입의 의존성을 생성하고 DependencyContainer에 등록하는 로직을 포함합니다.
public struct Module {
  /// registrationClosure는 비동기 클로저로, 해당 모듈의 의존성을 DependencyContainer에 등록하는 작업을 수행합니다.
  private let registrationClosure: () async -> Void
  
  /// 생성자
  ///
  /// - Parameters:
  ///   - type: 등록할 의존성의 타입. (예: AuthRepositoryProtocol.self)
  ///   - factory: 해당 타입의 인스턴스를 생성하는 팩토리 클로저.
  ///
  /// 생성자에서는 전달받은 타입과 팩토리 클로저를 이용하여,
  /// DependencyContainer.live를 통해 의존성을 등록하는 비동기 클로저를 생성하여 registrationClosure에 저장합니다.
  public init<T>(_ type: T.Type, factory: @escaping () -> T) {
    self.registrationClosure = {
      // DependencyContainer.live에 의존성을 등록합니다.
      // 이때, 'build' 매개변수로 factory 클로저를 전달하여 의존성 인스턴스를 생성합니다.
      DependencyContainer.live.register(type, build: factory)
    }
  }
  
  /// register() 메서드는 registrationClosure를 실행하여, 비동기적으로 의존성을 등록합니다.
  /// 호출 시 await를 사용하여 완료될 때까지 대기합니다.
  public func register() async {
    await registrationClosure()
  }
}
