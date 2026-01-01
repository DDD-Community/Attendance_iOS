import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Member",
  bundleId: .appBundleID(name: ".Member"),
  product: Project.Environment.presentationProduct,
  settings:  .settings(),
  dependencies: [
//    .SPM.composableArchitecture,
//    .SPM.tcaCoordinator,
//    .Shared(implements: .Shareds),
//    .Shared(implements: .DesignSystem),
    .Presentation(implements: .Profile),
//    .Core(implements: .Core)

  ],
  sources: ["Sources/**"]
)
