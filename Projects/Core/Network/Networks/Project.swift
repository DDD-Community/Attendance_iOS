import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "Networks",
  bundleId: .appBundleID(name: ".Networks"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .Service),
    .Network(implements: .Foundations),
  ],
  sources: ["Sources/**"]
)
