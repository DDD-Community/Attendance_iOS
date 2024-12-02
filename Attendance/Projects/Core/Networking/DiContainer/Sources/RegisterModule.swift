//
//  RegisterModule.swift
//  DiContainer
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

public struct RegisterModule {
  public init() {}
  
  public func makeModule<T>(_ type: T.Type, factory: @escaping () -> T) -> Module {
      Module(type, factory: factory)
  }
}
