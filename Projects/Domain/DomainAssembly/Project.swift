//
//  Project.swift
//  DomainAssembly
//
//  Created by DDD on 9/1/26.
//

import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DomainAssembly",
  bundleId: .appBundleID(name: ".DomainAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  // 도메인 레이어의 단일 출입구. 데이터·서비스는 보지 않는다.
  dependencies: [
    .core(.logger),
    .domain(.entity),
    .domain(.domainInterface),
    .domain(.useCase)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  requiresTCAHost: true
)
