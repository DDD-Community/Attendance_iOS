import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Model",
  bundleId: .appBundleID(name: ".Model"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .SPM.firebaseAuth,
    .SPM.firebaseFirestore
  ],
  sources: ["Sources/**"]
)
