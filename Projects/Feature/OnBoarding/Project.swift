import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "OnBoarding",
  bundleId: .appBundleID(name: ".OnBoarding"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.sharedUI),
    .core(.logger),
    .domain(.onBoarding),
    .domain(.profile)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.composableArchitecture
  ],
  hasDemo: true
)
