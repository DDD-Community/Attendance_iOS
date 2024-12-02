//
//  Container.swift
//  DiContainer
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

@Observable
public class Container {
    private var modules: [Module] = []

    public init() {}

    // Register a single module
    @discardableResult
    public func register(_ module: Module) -> Self {
        modules.append(module)
        return self
    }

    // Process the trailing closure
    @discardableResult
    public func callAsFunction(_ block: () -> Void) -> Self {
        block() // Execute the trailing closure
        return self
    }

    // Build and execute all module registrations
    public func build() async {
        for module in modules {
            await module.register()
        }
    }
}
