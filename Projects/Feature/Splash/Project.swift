import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Splash",
  bundleId: .appBundleID(name: ".Splash"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.sharedUI),
    .domainAssembly
  ],
  testDependencies: [
    .domain(.entity, .testing)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasTesting: true,
  hasDemo: true
)
