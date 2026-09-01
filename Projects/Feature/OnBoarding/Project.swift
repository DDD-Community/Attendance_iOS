import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "OnBoarding",
  bundleId: .appBundleID(name: ".OnBoarding"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.coreUtility),
    .core(.coreUI),
    .domain(.useCase),
    .ui(.sharedUI)  
  ],
  sources: ["Sources/**"],
  hasTests: true
)
