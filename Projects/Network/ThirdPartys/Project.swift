import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "ThirdPartys",
  bundleId: .appBundleID(name: ".ThirdPartys"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .SPM.asyncMoya,
    .SPM.weaveDI
  ],
  sources: ["Sources/**"],
  hasTests: false
)
