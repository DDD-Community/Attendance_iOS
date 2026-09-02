//
//  Project.swift
//  DataAssembly
//
//  Created by DDD on 9/1/26.
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
  // DomainAssembly가 제공하는 도메인 단일 진입점에 Repository 구현을 바인딩한다.
  // FeatureAssembly가 조립 사슬에 포함하고 Domain 계층은 이 모듈을 알지 않는다.
  dependencies: [
    .domainAssembly,
    .service,
    .core(.network, .interface),
    .data(.model),
    .data(.repository)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  requiresTCAHost: true
)
