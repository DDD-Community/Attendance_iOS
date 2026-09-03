import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Auth",
  bundleId: .appBundleID(name: ".Auth"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.sharedUI),
    .core(.logger),
    .domain(.auth)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.composableArchitecture
  ],
  hasDemo: true
)
