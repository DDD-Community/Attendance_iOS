//
//  Project.swift
//  FeatureAssembly
//
//  Created by DDD on 9/4/26.
//

import DependencyPlugin
import DependencyPackagePlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "FeatureAssembly",
  bundleId: .appBundleID(name: ".FeatureAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    // App은 이 모듈의 bootstrap 하나만 호출하고, DomainAssembly가 컨텍스트 구현을 조립한다.
    .domainAssembly,
    .feature(.auth),
    .feature(.management),
    .feature(.member),
    .feature(.onBoarding),
    .feature(.profile),
    .feature(.web),
    .feature(.sharedUI),
    .service(.auth, .interface),
    .core(.logger),
    .ui(.animation),
    .SPM.dependencies
  ],
  sources: ["Sources/**"]
)
