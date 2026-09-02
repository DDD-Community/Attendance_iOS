import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Web",
  bundleId: .appBundleID(name: ".Web"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .ui(.sharedUI),
    .domainAssembly
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.composableArchitecture
  ],
  hasDemo: true
)
