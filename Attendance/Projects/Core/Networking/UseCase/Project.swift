import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "UseCase",
  bundleId: .appBundleID(name: ".UseCase"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Networking(implements: .Model),
    .Networking(implements: .ThirdPartys),
    .Networking(implements: .DiContainer),
    .SPM.composableArchitecture,
    .SPM.googleSignIn,
    .SPM.firebaseDatabase
  ],
  sources: ["Sources/**"]
)
