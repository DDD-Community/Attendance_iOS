//
//  AppDIContainer.swift
//  DiContainer
//
//  Created by Wonji Suh  on 3/20/25.
//

import Foundation

public final actor AppDIContainer {
  
  private init() {}

  @MainActor public static let shared: AppDIContainer = .init()
  
  private let container = Container()
  
  /// registerDependencies 메서드는 비동기 클로저를 받아, 해당 클로저에서 의존성 모듈들을 등록하도록 합니다.
  /// 이후 container.build()를 호출하여, 등록된 모든 모듈의 register() 메서드를 비동기적으로 실행합니다.
  ///
  /// - Parameter registerModules: Container를 인자로 받아 비동기적으로 의존성 모듈들을 등록하는 클로저.
  /// - Note: 이 클로저는 앱(또는 라이브러리 사용자)이 원하는 의존성 등록 로직을 제공할 수 있도록 합니다.
  public func registerDependencies(
    registerModules: @escaping (Container) async -> Void
  ) async {
    // 로컬 상수에 container를 복사하여 self를 캡처하지 않도록 합니다.
    let containerCopy = container
    
    // 1. 전달받은 비동기 클로저를 로컬 containerCopy를 사용하여 실행합니다.
    await registerModules(containerCopy)
    
    // 2. containerCopy에 등록된 모든 모듈의 register()를 비동기적으로 실행합니다.
    await containerCopy {
      // 이 클로저는 비어있지만, callAsFunction 메서드를 통해 메서드 체이닝이 가능합니다.
    }.build()
  }
}
