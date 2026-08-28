//
//  ConfiguratuonEnviroment.swift
//  DependencyPackagePlugin
//
//  Created by DDD on 7/31/25.
//

import Foundation

public enum ConfigurationEnvironment: CaseIterable {
    case dev, stage, prod

    public var name: String {
        switch self {
        case .dev: "Dev"
        case .stage: "Stage"
        case .prod: "Prod"
        }
    }
}
