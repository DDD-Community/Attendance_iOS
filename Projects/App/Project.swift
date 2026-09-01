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

    // 조립 레이어 — Navigation 의 Coordinator 들이 각 피처 화면을 붙인다.
    .feature(.auth),
    .feature(.splash),
    .feature(.onBoarding),
    .feature(.management),
    .feature(.member),
    .feature(.profile),
    .feature(.web)
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements")
)
