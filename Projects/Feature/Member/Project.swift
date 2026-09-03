import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Member",
  bundleId: .appBundleID(name: ".Member"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.sharedUI),
    .core(.logger),
    .domain(.attendance),
    .domain(.myPage),
    .domain(.profile),
    .domain(.qrCode),
    .domain(.vote)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.composableArchitecture
  ],
  hasDemo: true
)
