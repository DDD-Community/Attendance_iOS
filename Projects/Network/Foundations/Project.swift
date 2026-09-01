import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Foundations",
  bundleId: .appBundleID(name: ".Foundations"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .network(.thirdPartys),
    .domain(.useCase)
  ],
  sources: ["Sources/**"],
  hasTests: false
)
