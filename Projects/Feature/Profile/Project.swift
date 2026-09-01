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
    .ui(.sharedUI),
    .domainAssembly
  ],
  sources: ["Sources/**"],
  hasTests: true
)
