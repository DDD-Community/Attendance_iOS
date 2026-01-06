import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Foundations",
  bundleId: .appBundleID(name: ".Foundations"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .ThirdPartys),
    
  ],
  sources: ["Sources/**"]
)
