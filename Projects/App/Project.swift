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
  // App 은 Feature·Data 조립 레이어를 병렬로 연결하는 최종 Composition Root 다.
  // Domain 계층이 Data 구현을 알지 않도록 라이브 구현 링크 책임을 여기에 둔다.
  dependencies: [
    .featureAssembly,
    .dataAssembly
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements"),
  hasTests: true
)
