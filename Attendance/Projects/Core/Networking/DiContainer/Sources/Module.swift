//
//  Module.swift
//  DiContainer
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

public struct Module {
    private let registrationClosure: () async -> Void

    public init<T>(_ type: T.Type, factory: @escaping () -> T) {
        self.registrationClosure = {
            await DependencyContainer.live.register(type, build: factory)
        }
    }

    public func register() async {
        await registrationClosure()
    }
}
