//
//  Project.swift
//  DDDCoreUI
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
    name: "DDDCoreUI",
    bundleId: .appBundleID(name: ".DDDCoreUI"),
    product: .staticFramework,
    settings: .moduleSettings,
    dependencies: [],
    sources: ["Sources/**"],
    hasTests: true
)
