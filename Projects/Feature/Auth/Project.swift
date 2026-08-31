import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin


let project = Project.makeModule(
  name: "Auth",
  bundleId: .appBundleID(name: ".Auth"),
  product: Project.Environment.presentationProduct,
  settings:  .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.coreUtility),
    .core(.coreUI),
    .ui(.sharedUI),
    .domain(.useCase),
    .feature(.onBoarding),
    .feature(.web)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
