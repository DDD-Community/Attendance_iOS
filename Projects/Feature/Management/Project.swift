import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Management",
  bundleId: .appBundleID(name: ".Management"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.sharedUI),
    .feature(.sharedUI),
    .core(.logger),
    .domain(.attendance),
    .domain(.qrCode),
    .domain(.schedule),
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
