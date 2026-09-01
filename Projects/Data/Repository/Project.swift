import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Repository",
  bundleId: .appBundleID(name: ".Repository"),
  product: .staticFramework,
  settings: .repositoryBaseSettings(),
  dependencies: [
    .core(.logger),
    .data(.service),
    .data(.model),
    .domain(.domainInterface),
    .domain(.entity),
    .network(.foundations),
    .SPM.asyncMoya,
    .SPM.composableArchitecture,
    .SPM.googleSignIn
  ],
  sources: ["Sources/**"],
  hasTests: true
)
