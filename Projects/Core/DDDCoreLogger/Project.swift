import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDCoreLogger",
  bundleId: .appBundleID(name: ".DDDCoreLogger"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [],
  sources: ["Sources/**"]
)
