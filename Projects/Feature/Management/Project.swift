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
    .domainAssembly
  ],
  testDependencies: [
    .domain(.entity, .testing)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasDemo: true
)
