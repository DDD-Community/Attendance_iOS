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
    .Core(implements: .DDDCoreLogger),
    .Core(implements: .DDDCoreUtility),
    .Core(implements: .DDDCoreUI),
    .UI(implements: .DDDSharedUI),
    .Presentation(implements: .Profile),
    .Domain(implements: .UseCase)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
