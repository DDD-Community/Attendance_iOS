//
//  Project.swift
//  Manifests
//
//  Created by 서원지 on 6/7/24.
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
    .Shared(implements: .Shareds),
    .Networking(implements: .Networkings),
    .Presentation(implements: .Presentation)
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements")
)
