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
  // App은 FeatureAssembly 하나만 알고, Repository·Service 구현 조립은 하위 Assembly가 담당한다.
  dependencies: [
    .featureAssembly,
  ],
  testDependencies: [
    .featureAssembly,
    .domain(.entity, .testing),
    .domain(.domainInterface)
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements"),
  hasTests: true
)
