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
      .network(.thirdPartys),
      .data(.api),
      .network(.foundations),
    ],
    sources: ["Sources/**"]
)
