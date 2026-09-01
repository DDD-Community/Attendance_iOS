import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin


let project = Project.makeModule(
  name: "Auth",
  bundleId: .appBundleID(name: ".Auth"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.coreUtility),
    .core(.coreUI),
    .ui(.sharedUI),
    .domain(.domainInterface),
    .domain(.useCase)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
