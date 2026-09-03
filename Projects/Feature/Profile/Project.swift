import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Profile",
  bundleId: .appBundleID(name: ".Profile"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.sharedUI),
    .core(.logger),
    .domain(.auth),
    .domain(.profile)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.composableArchitecture
  ],
  hasDemo: true
)
