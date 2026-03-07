import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Entity",
  bundleId: .appBundleID(name: ".Entity"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [

    .SPM.composableArchitecture,
  
  ],
  sources: ["Sources/**"],
  hasTests: false
)
