import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Member",
  bundleId: .appBundleID(name: ".Member"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .ui(.sharedUI),
    .domain(.useCase)

  ],
  sources: ["Sources/**"],
  hasTests: true
)
