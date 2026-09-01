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
  // DomainInterface 의 프로토콜에 Repository 구현을 바인딩하는 지점이라
  // 도메인과 데이터를 동시에 아는 유일한 모듈이다.
  dependencies: [
    .domainAssembly,
    .service,
    .core(.network, .interface),
    .data(.model),
    .data(.repository)
  ],
  sources: ["Sources/**"]
)
