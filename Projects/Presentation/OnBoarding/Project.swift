import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "OnBoarding",
  bundleId: .appBundleID(name: ".OnBoarding"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [

    .SPM.composableArchitecture,
    .SPM.tcaCoordinator,
    .Domain(implements: .UseCase),
    .Shared(implements: .Shareds)
  
  ],
  sources: ["Sources/**"]
)
