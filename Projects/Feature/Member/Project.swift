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
    .data(.model),
    .domainAssembly
  ],
  testDependencies: [
    .data(.model)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  requiresTCAHost: true
)
