//
//  Project.swift
//  DataAssembly
//
//  Created by DDD on 9/2/26.
//

import DependencyPlugin
import DependencyPackagePlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DataAssembly",
  bundleId: .appBundleID(name: ".DataAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  // FeatureAssembly에 Data 세부 구조를 노출하지 않고 라이브 구현을 조립한다.
  dependencies: [
    .core(.network, .interface),
    .data(.model),
    .data(.repository),
    .domainAssembly,
    .service,
    .SPM.dependencies
  ],
  sources: ["Sources/**"],
  hasTests: true,
  requiresTCAHost: true,
  forceLoadInTests: true
)
