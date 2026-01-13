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
  settings:  .settings(),
  dependencies: [

    .SPM.composableArchitecture,
    .SPM.tcaCoordinator,
    .Shared(implements: .Shareds),
    .Shared(implements: .DesignSystem),
    .Domain(implements: .UseCase)
  
  ],
  sources: ["Sources/**"]
)
