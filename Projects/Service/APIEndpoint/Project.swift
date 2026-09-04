//
//  Project.swift
//  APIEndpoint
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "APIEndpoint",
  bundleId: .appBundleID(name: ".APIEndpoint"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .core(.network, .interface),
    .service(.api),
    .domain(.vote, .interface),
    .SPM.alamofire
  ],
  sources: ["Sources/**"],
  hasTests: true
)
