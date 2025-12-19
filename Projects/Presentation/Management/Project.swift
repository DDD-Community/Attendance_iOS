import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Management",
  bundleId: .appBundleID(name: ".Management"),
  product: Project.Environment.presentationProduct,
  settings:  .settings(),
  dependencies: [

    .SPM.composableArchitecture,
    .SPM.tcaCoordinator,
    .Shared(implements: .Shareds),
    .Domain(implements: .UseCase),
    .Presentation(implements: .Profile),
    .Core(implements: .Core)

  ],
  sources: ["Sources/**"]
)
