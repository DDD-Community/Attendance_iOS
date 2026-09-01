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
  sources: ["Sources/**"],
  hasTests: true
)
