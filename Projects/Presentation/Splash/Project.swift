import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Splash",
  bundleId: .appBundleID(name: ".Splash"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .SPM.composableArchitecture,
    .SPM.tcaCoordinator,
    .Shared(implements: .Shareds),
    .Shared(implements: .DesignSystem),
    .Domain(implements: .UseCase),
    .Core(implements: .Core)

  ],
  sources: ["Sources/**"],
  hasTests: true
)
