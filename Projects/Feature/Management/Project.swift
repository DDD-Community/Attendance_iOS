import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Management",
  bundleId: .appBundleID(name: ".Management"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .ui(.sharedUI),
    .feature(.sharedUI),
    .domainAssembly
  ],
  sources: ["Sources/**"],
  hasTests: true
)
