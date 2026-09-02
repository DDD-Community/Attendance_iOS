//
//  Project.swift
//  DataAssembly
//
//  Created by DDD on 9/2/26.
//

import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DataAssembly",
  bundleId: .appBundleID(name: ".DataAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  // DataAssembly는 Data 모듈의 진입점만 제공한다.
  // DomainInterface의 라이브 구현 등록은 FeatureAssembly가 담당한다.
  dependencies: [
    .data(.model),
    .data(.repository)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  requiresTCAHost: true
)
