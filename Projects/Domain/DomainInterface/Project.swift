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
    .Data(implements: .Model),
    .SPM.weaveDI,
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: false
  
)
