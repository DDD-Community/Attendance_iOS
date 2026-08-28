import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Splash",
  bundleId: .appBundleID(name: ".Splash"),
  product: Project.Environment.presentationProduct,
  settings:  .moduleSettings,
  dependencies: [
    .Core(implements: .DDDCoreUtility),
    .UI(implements: .DDDSharedUI),
    .UI(implements: .DDDDesignKit),
    .Domain(implements: .UseCase)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
