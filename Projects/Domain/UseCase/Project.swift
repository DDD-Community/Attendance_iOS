import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "UseCase",
  bundleId: .appBundleID(name: ".UseCase"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .domain(.domainInterface)
    
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasTesting: true,
  requiresTCAHost: true,
  forceLoadInTests: true
)
