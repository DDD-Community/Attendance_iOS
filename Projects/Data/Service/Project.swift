import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
    name: "Service",
    bundleId: .appBundleID(name: ".Service"),
    product: .staticFramework,
    settings:  .moduleSettings,
    dependencies: [
      .Network(implements: .ThirdPartys),
      .Data(implements: .API),
      .Network(implements: .Foundations),
    ],
    sources: ["Sources/**"]
)
