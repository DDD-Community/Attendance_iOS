//
//  Project.swift
//  DomainAssembly
//
//  Created by DDD on 9/1/26.
//

import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DomainAssembly",
  bundleId: .appBundleID(name: ".DomainAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .dataAssembly,
    .domain(.entity),
    .domain(.domainInterface),
    .domain(.useCase)
  ],
  sources: ["Sources/**"]
)
