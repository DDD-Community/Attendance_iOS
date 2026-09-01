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
  // DomainInterface 의 프로토콜에 Repository 구현을 바인딩하는 지점.
  // 조립 사슬에서 ServiceAssembly 바로 위, DomainAssembly 바로 아래에 놓인다.
  dependencies: [
    .domain(.domainInterface),
    .domain(.entity),
    .service,
    .core(.network, .interface),
    .data(.model),
    .data(.repository)
  ],
  sources: ["Sources/**"]
)
