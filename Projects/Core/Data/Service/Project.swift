import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
    name: "Service",
    bundleId: .appBundleID(name: ".Service"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
      .Network(implements: .ThirdPartys),
      .Data(implements: .API),
      .Network(implements: .Foundations),
    ],
    sources: ["Sources/**"]
)
