import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDSharedUI",
  bundleId: .appBundleID(name: ".DDDSharedUI"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .UI(implements: .DDDDesignKit),
    .Core(implements: .DDDCoreUI),
    .Core(implements: .DDDCoreUtility),
    .Domain(implements: .Entity),
    .Data(implements: .Model),
  ],
  sources: ["Sources/**"]
)
