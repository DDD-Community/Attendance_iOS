import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Shareds",
  bundleId: .appBundleID(name: ".Shareds"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Shared(implements: .ThirdParty),
    .Shared(implements: .Utill),
    .Shared(implements: .DesignSystem)
  ],
  sources: ["Sources/**"]
)
