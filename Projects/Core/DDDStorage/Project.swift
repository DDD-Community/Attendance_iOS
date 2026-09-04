//
//  Project.swift
//  DDDStorage
//
//  Created by DDD on 9/1/26.
//

import DependencyPlugin
import DependencyPackagePlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDStorage",
  bundleId: .appBundleID(name: ".DDDStorage"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [.SPM.dependencies]
)
