import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Profile",
  bundleId: .appBundleID(name: ".Profile"),
  product: Project.Environment.presentationProduct,
  settings:  .moduleSettings,
  dependencies: [
    .Core(implements: .DDDCoreLogger),
    .Core(implements: .DDDCoreUI),
    .UI(implements: .DDDSharedUI),
    .Domain(implements: .UseCase),
    .Presentation(implements: .OnBoarding),
    .Presentation(implements: .Web)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
