import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Networks",
  bundleId: .appBundleID(name: ".Networks"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .network(.foundations),
  ],
  sources: ["Sources/**"],
  hasTests: false
)
