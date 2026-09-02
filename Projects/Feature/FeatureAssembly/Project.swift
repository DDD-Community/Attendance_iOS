import Foundation
import ProjectDescription
import DependencyPlugin
import DependencyPackagePlugin
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
    .core(.network, .interface),
    .data(.repository),
    .domain(.domainInterface),
    .service,
    .SPM.dependencies
  ],
  sources: ["Sources/**"],
  hasTests: true,
  requiresTCAHost: true,
  forceLoadInTests: true
)
