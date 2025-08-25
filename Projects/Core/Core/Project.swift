import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "Core",
  bundleId: .appBundleID(name: ".Core"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .Networks),
    .Domain(implements: .UseCase)
  ],
  sources: ["Sources/**"]
)
