import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Splash",
  bundleId: .appBundleID(name: ".Splash"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .core(.coreUtility),
    .ui(.sharedUI),
    .core(.logger),
    .ui(.designKit),
    .domain(.useCase)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
