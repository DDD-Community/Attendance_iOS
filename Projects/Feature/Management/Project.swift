import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Management",
  bundleId: .appBundleID(name: ".Management"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.coreUtility),
    .core(.coreUI),
    .ui(.sharedUI),
    .domain(.useCase)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
