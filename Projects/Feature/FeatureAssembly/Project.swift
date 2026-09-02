import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "FeatureAssembly",
  bundleId: .appBundleID(name: ".FeatureAssembly"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    .feature(.auth),
    .feature(.splash),
    .feature(.management),
    .feature(.member),
    .feature(.onBoarding),
    .feature(.profile),
    .feature(.web),
    .feature(.sharedUI),
    .dataAssembly
  ],
  sources: ["Sources/**"],
  hasTests: true,
  forceLoadInTests: true,
  forceLoadDependenciesInTests: ["DataAssembly"]
)
