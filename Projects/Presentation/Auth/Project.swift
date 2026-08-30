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
  settings:  .moduleSettings,
  dependencies: [
    .Core(implements: .DDDCoreLogger),
    .Core(implements: .DDDCoreUtility),
    .Core(implements: .DDDCoreUI),
    .UI(implements: .DDDSharedUI),
    .Domain(implements: .UseCase),
    .Presentation(implements: .OnBoarding),
    .Presentation(implements: .Web)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
