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
    .core(.logger),
    .core(.coreUI),
    .ui(.sharedUI),
    .domain(.useCase),
    .presentation(.onBoarding),
    .presentation(.web)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
