import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Management",
  bundleId: .appBundleID(name: ".Management"),
  product: Project.Environment.presentationProduct,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.coreUtility),
    .core(.coreUI),
    .ui(.sharedUI),
    .feature(.profile),
    .domain(.useCase)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
