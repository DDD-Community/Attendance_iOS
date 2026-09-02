import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Repository",
  bundleId: .appBundleID(name: ".Repository"),
  product: .staticFramework,
  settings: .repositoryBaseSettings(),
  dependencies: [
    .core(.logger),
    .core(.network, .interface),
    .service(.auth, .interface),
    .service(.apiEndpoint),
    .data(.model),
    .domain(.domainInterface),
    .domain(.entity),
    .SPM.composableArchitecture,
    .SPM.googleSignIn
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasTesting: true
)
