import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Networks",
  bundleId: .appBundleID(name: ".Networks"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .Foundations),
  ],
  sources: ["Sources/**"],
  hasTests: false
)
