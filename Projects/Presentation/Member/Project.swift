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
    .Core(implements: .DDDCoreLogger),
    .UI(implements: .DDDSharedUI),
    .Presentation(implements: .Profile),
    .Domain(implements: .UseCase)

  ],
  sources: ["Sources/**"],
  hasTests: true
)
