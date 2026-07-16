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
    .Network(implements: .ThirdPartys),
    .Domain(implements: .UseCase)
  ],
  sources: ["Sources/**"],
  hasTests: false
)
