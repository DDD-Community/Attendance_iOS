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
  // App 은 조립 레이어 하나만 본다. 피처·Repository·UseCase 는
  // FeatureAssembly 가 묶어서 @_exported 로 다시 내보낸다.
  dependencies: [
    .featureAssembly
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements"),
  hasTests: true
)
