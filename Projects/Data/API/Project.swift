import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "API",
  bundleId: .appBundleID(name: ".API"),
  product: .staticFramework,
  settings: .settings(
    base: [
      "SWIFT_ENABLE_EXPLICIT_MODULES": "NO"
    ]
  ),
  dependencies: [
    .Network(implements: .ThirdPartys),
    .SPM.asyncMoya  // 직접 의존성 추가
  ],
  sources: ["Sources/**"],
  hasTests: false
)
