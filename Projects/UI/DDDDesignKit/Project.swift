import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDDesignKit",
  bundleId: .appBundleID(name: ".DDDDesignKit"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .Core(implements: .DDDCoreUI),
    .Core(implements: .DDDThirdParty),
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"]
)
