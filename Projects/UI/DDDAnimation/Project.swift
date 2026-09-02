//
//  Project.swift
//  DDDAnimation
//
//  Created by DDD on 9/1/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDAnimation",
  bundleId: .appBundleID(name: ".DDDAnimation"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .SPM.sdwebImage
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  hasTests: true
)
