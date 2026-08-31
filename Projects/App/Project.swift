//
//  Project.swift
//  Manifests
//
//  Created by DDD on 6/7/24.
//

import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
  name: Project.Environment.appName,
  bundleId: .mainBundleID(),
  product: .app,
  settings: .appMainSetting,
  scripts: [],
  dependencies: [
    .core(.logger),
    .core(.coreUtility),
    .ui(.sharedUI),
    .featureAssembly,
    .data(.repository),
    .domain(.domainInterface),
    .domain(.useCase),
    .network(.foundations)
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements")
)
