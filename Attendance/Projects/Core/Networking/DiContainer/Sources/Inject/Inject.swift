//
//  Inject.swift
//  DiContainer
//
//  Created by Wonji Suh  on 3/20/25.
//

/// @Inject 프로퍼티 래퍼는 지정된 타입의 의존성을 DI 컨테이너(기본값: DependencyContainer.live)에서 조회하여 주입받습니다.
/// 만약 해당 타입의 의존성이 컨테이너에 등록되어 있지 않다면, fatalError를 발생시켜 앱이 즉시 종료됩니다.
///

import Foundation

@propertyWrapper
public struct Inject<T> {
  /// 의존성을 조회할 때 사용할 DI 컨테이너입니다.
  /// 기본적으로 전역 공유 인스턴스인 DependencyContainer.live가 사용됩니다.
  private let container: DependencyContainer
  
  /// 주입받은 의존성이 저장되는 프로퍼티입니다.
  public var wrappedValue: T
  
  /// 초기화 메서드
  /// - Parameter container: 의존성을 조회할 DI 컨테이너. 기본값은 DependencyContainer.live입니다.
  ///
  /// 이 이니셜라이저는 컨테이너에서 타입 T에 해당하는 의존성을 조회하여 wrappedValue에 할당합니다.
  /// 만약 컨테이너에서 의존성을 찾지 못하면, fatalError를 호출하여 앱이 중단됩니다.
  public init(
    container: DependencyContainer = .live
  ) {
    self.container = container
    
    // 컨테이너에서 타입 T에 해당하는 의존성을 조회합니다.
    guard let dependency: T = container.resolve(T.self) else {
      fatalError("No registered dependency found for \(T.self)")
    }
    
    // 조회된 의존성을 wrappedValue에 할당합니다.
    self.wrappedValue = dependency
  }
}
