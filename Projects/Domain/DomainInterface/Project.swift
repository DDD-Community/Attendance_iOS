import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "DomainInterface",
  bundleId: .appBundleID(name: ".DomainInterface"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [

    .data(.model),
    .SPM.dependencies,
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: false

)
