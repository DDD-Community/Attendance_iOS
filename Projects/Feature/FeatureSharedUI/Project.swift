//
//  Project.swift
//  FeatureSharedUI
//
//  Created by DDD on 9/1/26.
//

import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "FeatureSharedUI",
  bundleId: .appBundleID(name: ".FeatureSharedUI"),
  product: .staticFramework,
  settings: .moduleSettings,
  // 도메인 타입을 아는 공용 뷰가 사는 곳. DDDSharedUI 는 도메인을 몰라야 하므로
  // Entity 를 참조하는 컴포넌트는 피처 레이어인 여기로 올린다.
  dependencies: [
    .ui(.sharedUI),
    .domainAssembly
  ],
  sources: ["Sources/**"]
)
