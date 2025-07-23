import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "Networkings",
  bundleId: .appBundleID(name: ".Networkings"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .API),
    .Network(implements: .Service),
    .Network(implements: .ThirdPartys),
    .Network(implements: .Foundations),
    .Network(implements: .UseCase),
  ],
  sources: ["Sources/**"]
)
