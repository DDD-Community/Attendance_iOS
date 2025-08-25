import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
  name: "Foundations",
  bundleId: .appBundleID(name: ".Foundations"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .ThirdPartys),
    .Network(implements: .API),
    .Data(implements: .Model)
  ],
  sources: ["Sources/**"]
)
