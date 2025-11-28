//
//  Extension+Configuration.swift
//  DependencyPackagePlugin
//
//  Created by Wonji Suh  on 7/31/25.
//

import Foundation
import ProjectDescription

extension ConfigurationName {
    static let dev = ConfigurationName.configuration(ConfiguratuonEnviroment.dev.name)
    static let stage = ConfigurationName.configuration(ConfiguratuonEnviroment.stage.name)
    static let prod = ConfigurationName.configuration(ConfiguratuonEnviroment.prod.name)
}

public extension Array where Element == Configuration {
    static let `default`: [Configuration] = [
        .debug(name: .dev, xcconfig: .path(.dev)),
        .debug(name: .stage, xcconfig: .path(.stage)),
        .debug(name: .prod, xcconfig: .path(.prod)),
        .release(name: .release, xcconfig: .path(.release))
    ]
}

public extension ProjectDescription.Path {
    static func path(_ configuration: ConfigurationName) -> Self {
        return .relativeToRoot("Config/\(configuration.rawValue).xcconfig")
    }
}
