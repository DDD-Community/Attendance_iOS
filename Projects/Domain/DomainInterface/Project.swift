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

    .domain(.entity),
    .SPM.dependencies,
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: true

)
