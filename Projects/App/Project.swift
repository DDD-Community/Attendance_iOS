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
    .Presentation(implements: .Presentation),
    .Data(implements: .Repository),
    .Domain(implements: .DomainInterface),
    .Domain(implements: .UseCase),
    .Network(implements: .Foundations),
    .Presentation(implements: .Auth)
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements")
)
