import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Auth",
  bundleId: .appBundleID(name: ".Auth"),
  product: Project.Environment.presentationProduct,
  settings:  .settings(),
  dependencies: [
    .Shared(implements: .Shareds),
    .Shared(implements: .DesignSystem),
    .Core(implements: .Core)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
