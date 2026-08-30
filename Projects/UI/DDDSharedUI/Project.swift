import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDSharedUI",
  bundleId: .appBundleID(name: ".DDDSharedUI"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.designKit),
    .core(.coreUI),
    .core(.coreUtility),
    .domain(.entity),
    .data(.model),
  ],
  sources: ["Sources/**"]
)
