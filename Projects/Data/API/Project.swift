import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "API",
  bundleId: .appBundleID(name: ".API"),
  product: .staticFramework,
  settings: .settings(
    base: [
      "SWIFT_ENABLE_EXPLICIT_MODULES": "NO"
    ],
    configurations: .moduleDefault
  ),
  dependencies: [
    .network(.thirdPartys),
    .SPM.asyncMoya // 직접 의존성 추가
  ],
  sources: ["Sources/**"],
  hasTests: false
)
