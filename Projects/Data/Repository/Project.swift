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
    .Core(implements: .DDDCoreLogger),
    .Data(implements: .Service),
    .Data(implements: .Model),
    .Domain(implements: .DomainInterface),
    .Domain(implements: .Entity),
    .Network(implements: .Foundations),
    .SPM.asyncMoya,
    .SPM.composableArchitecture,
    .SPM.googleSignIn
  ],
  sources: ["Sources/**"],
  hasTests: true
)
