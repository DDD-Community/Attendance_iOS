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
  settings:  .settings(),
  dependencies: [
    .Shared(implements: .Shareds),
    .Domain(implements: .UseCase),
    .Presentation(implements: .OnBoarding)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
