//
//  DIContainer.swift
//  DiContainer
//
//  Created by 서원지 on 6/8/24.
//

import Foundation

import AsyncMoya

/// DependencyContainer는 애플리케이션 내 의존성(또는 팩토리 클로저)을 등록, 조회 및 해제하는 역할을 합니다.
/// 내부적으로 의존성을 ObjectIdentifier를 키로 관리하며, 이를 통해 타입 기반 의존성 주입을 구현합니다.
/// 
 @Observable
public final class DependencyContainer: @unchecked Sendable {
  
  // 의존성(또는 팩토리 클로저)을 저장하는 딕셔너리.
  private var registry = [String: Any]()
  
  // 등록된 의존성을 해제하기 위한 핸들러들을 저장하는 딕셔너리.
  private var releaseHandlers = [String: () -> Void]()
  
  // 동기화 전용 concurrent DispatchQueue.
  private let syncQueue = DispatchQueue(label: "com.diContainer.syncQueue", attributes: .concurrent)
  
  public init() {}
  
  /// 주어진 타입의 의존성을 등록합니다.
  /// - Parameters:
  ///   - type: 등록할 의존성의 타입 (예: AuthRepositoryProtocol.self)
  ///   - build: 해당 타입의 인스턴스를 생성하는 팩토리 클로저
  /// - Returns: 나중에 해당 의존성을 해제할 때 사용할 해제 클로저
  @discardableResult
  public func register<T>(
    _ type: T.Type,
    build: @escaping () -> T
  ) -> () -> Void {
    let key = String(describing: type)
    
    // 동기적으로 registry에 build 클로저를 저장합니다.
    syncQueue.sync(flags: .barrier) {
      self.registry[key] = build
    }
    Log.debug("Registered", key)
    
    // 해제 클로저: 해당 키의 값을 제거합니다.
    let releaseHandler: () -> Void = { [weak self] in
      self?.syncQueue.sync(flags: .barrier) {
        self?.registry[key] = nil
        self?.releaseHandlers[key] = nil
      }
      Log.debug("Released", key)
    }
    
    // 동기적으로 releaseHandlers에도 저장합니다.
    syncQueue.sync(flags: .barrier) {
      self.releaseHandlers[key] = releaseHandler
    }
    
    return releaseHandler
  }
  
  /// 주어진 타입의 의존성을 조회하여 인스턴스를 생성합니다.
  /// - Parameter type: 조회할 의존성의 타입
  /// - Returns: 등록된 의존성이 있으면 생성된 인스턴스, 없으면 nil
  public func resolve<T>(_ type: T.Type) -> T? {
    let key = String(describing: type)
    return syncQueue.sync { [unowned self] in
      guard let factory = self.registry[key] as? () -> T else {
        #logError("No registered dependency found for \(String(describing: T.self))")
        return nil
      }
      return factory()
    }
  }
  
  /// 주어진 타입의 의존성을 조회하거나, 등록되어 있지 않으면 기본값을 반환합니다.
  public func resolveOrDefault<T>(
    _ type: T.Type,
    default defaultValue: @autoclosure () -> T
  ) -> T {
    resolve(type) ?? defaultValue()
  }
  
  /// 특정 타입의 의존성을 해제합니다.
  public func release<T>(_ type: T.Type) {
    let key = String(describing: type)
    syncQueue.async(flags: .barrier) { [unowned self] in
      self.releaseHandlers[key]?()
    }
  }
  
  /// KeyPath 기반 접근: 타입 기반 resolve를 호출합니다.
  public subscript<T>(keyPath: KeyPath<DependencyContainer, T>) -> T? {
    get { resolve(T.self) }
  }
  
  /// 이미 생성된 인스턴스를 클로저로 래핑하여 등록합니다.
  /// Sendable 제약을 제거하여, instance가 Sendable하지 않아도 등록할 수 있습니다.
  public func register<T: Sendable>(
    _ type: T.Type,
    instance: T
  ) {
    let key = String(describing: type)
    syncQueue.async(flags: .barrier) { [unowned self] in
      // @Sendable 캐스트를 제거하여 instance 캡처 오류 해결
      self.registry[key] = { instance }
    }
    #logDebug("Registered instance for", key)
  }
}
/// DependencyContainer의 공용(live) 인스턴스를 제공하는 extension입니다.
public extension DependencyContainer {
  static let live = DependencyContainer()
}
