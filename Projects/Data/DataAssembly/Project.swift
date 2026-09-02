//
//  Project.swift
//  DataAssembly
//
//  Created by DDD on 9/2/26.
//

import DependencyPlugin
import DependencyPackagePlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DataAssembly",
  bundleId: .appBundleID(name: ".DataAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  // FeatureAssembly에 Data 세부 구조를 노출하지 않고 라이브 구현을 조립한다.
  dependencies: [
    .core(.network, .interface),
    .data(.model),
    .data(.repository),
    // Repository 라이브 구현을 DomainInterface 의 DependencyKey 에 꽂는 게 이 모듈의 역할이라
    // DomainInterface 만 있으면 된다. DomainAssembly 를 의존하면 Data 가 Domain 의 UseCase 구현을
    // 링크하게 되어 계층 방향이 역행한다. UseCase 조립은 FeatureAssembly 가 맡는다.
    .domain(.domainInterface),
    .serviceAssembly,
    .SPM.dependencies
  ],
  sources: ["Sources/**"],
  hasTests: true,
  forceLoadInTests: true
)
