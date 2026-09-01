//
//  Project.swift
//  DDDAnimation
//
//  Created by DDD on 9/1/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDAnimation",
  bundleId: .appBundleID(name: ".DDDAnimation"),
  product: .framework,
  settings: .moduleSettings,
  // 애니메이션 재생 라이브러리를 감싸는 유일한 지점.
  // 호출부는 SDWebImageSwiftUI 를 직접 import 하지 않는다.
  dependencies: [
    .SPM.sdwebImage
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  hasTests: true
)
