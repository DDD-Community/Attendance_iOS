//
//  Project.swift
//  ServiceAssembly
//
//  Created by DDD on 9/1/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "ServiceAssembly",
  bundleId: .appBundleID(name: ".ServiceAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .core(.assembly),
    .core(.storage, .interface),
    .service(.auth, .implementation),
    .domain(.domainInterface),
    .SPM.dependencies
  ],
  sources: ["Sources/**"],
  hasTests: true
)
