import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "API",
  bundleId: .appBundleID(name: ".API"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .SPM.asyncMoya
  ],
  sources: ["Sources/**"],
  infoPlist: .moduleInfoPlist
)
