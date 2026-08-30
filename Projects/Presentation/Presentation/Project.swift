import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Presentation",
  bundleId: .appBundleID(name: ".Presentation"),
  product: Project.Environment.presentationProduct,
  settings:  .moduleSettings,
  dependencies: [
    .presentation(.auth),
    .presentation(.splash),
    .presentation(.management),
    .presentation(.member),
    .presentation(.onBoarding),
    .presentation(.profile),
    .presentation(.web)
  ],
  sources: ["Sources/**"]
)
