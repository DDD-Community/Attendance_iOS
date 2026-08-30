import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "OnBoarding",
  bundleId: .appBundleID(name: ".OnBoarding"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .Core(implements: .DDDCoreLogger),
    .Core(implements: .DDDCoreUtility),
    .Core(implements: .DDDCoreUI),
    .Domain(implements: .UseCase),
    .UI(implements: .DDDSharedUI)  
  ],
  sources: ["Sources/**"],
  hasTests: true
)
