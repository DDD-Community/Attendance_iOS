import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Member",
  bundleId: .appBundleID(name: ".Member"),
  product: Project.Environment.presentationProduct,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .ui(.sharedUI),
    .feature(.profile),
    .domain(.useCase)

  ],
  sources: ["Sources/**"],
  hasTests: true
)
