import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "UseCase",
  bundleId: .appBundleID(name: ".UseCase"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .SPM.composableArchitecture,
    .SPM.diContainer,
    .Data(implements: .Repository),
    .Domain(implements: .DomainInterface),
  ],
  sources: ["Sources/**"]
)
