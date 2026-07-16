import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Web",
  bundleId: .appBundleID(name: ".Web"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .Domain(implements: .UseCase),
    .Shared(implements: .Shareds)  

  ],
  sources: ["Sources/**"]
)
