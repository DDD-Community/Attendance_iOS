import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "ThirdPartys",
  bundleId: .appBundleID(name: ".ThirdPartys"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .SPM.asyncMoya,
    .SPM.firebaseFirestore
  ],
  sources: ["Sources/**"]
)
