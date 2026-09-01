import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Profile",
  bundleId: .appBundleID(name: ".Profile"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.coreUI),
    .ui(.sharedUI),
    .domainAssembly
  ],
  sources: ["Sources/**"],
  hasTests: true
)
