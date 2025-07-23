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
    .Data(implements: .Model),
    .Network(implements: .Service),
    .SPM.diContainer,
    .SPM.composableArchitecture,
    .SPM.googleSignIn,
    .SPM.firebaseDatabase
  ],
  sources: ["Sources/**"]
)
