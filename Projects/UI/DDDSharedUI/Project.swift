//
//  Project.swift
//  DDDSharedUI
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDSharedUI",
  bundleId: .appBundleID(name: ".DDDSharedUI"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.animation),
    .ui(.designKit),
    .core(.coreUI),
    .core(.coreUtility)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
