//
//  Project.swift
//  DDDCoreUtility
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
    name: "DDDCoreUtility",
    bundleId: .appBundleID(name: ".DDDCoreUtility"),
    product: .staticFramework,
    settings: .moduleSettings,
    dependencies: [
        .SPM.composableArchitecture,
    ],
    sources: ["Sources/**"],
    hasTests: true
)
