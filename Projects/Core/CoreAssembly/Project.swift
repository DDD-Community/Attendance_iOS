//
//  Project.swift
//  CoreAssembly
//
//  Created by DDD on 9/1/26.
//

import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "CoreAssembly",
  bundleId: .appBundleID(name: ".CoreAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.coreUI),
    .core(.coreUtility),
    .core(.network, .implementation),
    .core(.storage, .implementation)
  ],
  sources: ["Sources/**"]
)
