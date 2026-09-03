import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "UseCase",
  bundleId: .appBundleID(name: ".UseCase"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .domain(.domainInterface),
    .SPM.dependencies

  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasTesting: true
)
