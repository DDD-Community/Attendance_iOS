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
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .Entity),
    .Data(implements: .Model),
    .SPM.weaveDI,
    .SPM.dependencies,
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: false

)
