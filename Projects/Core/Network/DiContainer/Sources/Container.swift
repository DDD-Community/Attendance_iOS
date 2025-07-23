//
//  Container.swift
//  DiContainer
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

public actor Container {
  private var modules: [Module] = []
  
  public init() {}
  
  @discardableResult
  public func register(_ module: Module) -> Self {
    modules.append(module)
    return self
  }
  
  @discardableResult
  public func callAsFunction(_ block: () -> Void) -> Self {
    block()
    return self
  }
  
  public func build() async {
    await withTaskGroup(of: Void.self) { group in
      for module in modules {
        group.addTask {
          await module.register()
        }
      }
    }
  }
}

