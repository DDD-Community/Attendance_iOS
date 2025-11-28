//
//  ConfiguratuonEnviroment.swift
//  DependencyPackagePlugin
//
//  Created by Wonji Suh  on 7/31/25.
//

import Foundation

public enum ConfiguratuonEnviroment: CaseIterable {
    case dev, stage, prod

    public var name: String {
        switch self {
        case .dev: "Dev"
        case .stage: "Stage"
        case .prod: "Prod"
        }
    }
}
