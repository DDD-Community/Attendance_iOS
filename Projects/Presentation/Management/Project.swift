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
  settings:  .settings(),
  dependencies: [
    .Shared(implements: .Shareds),
    .Presentation(implements: .Profile),
    .Domain(implements: .UseCase)
  ],
  sources: ["Sources/**"]
)
