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
    .core(.coreUI),
    .core(.thirdParty),
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"]
)
