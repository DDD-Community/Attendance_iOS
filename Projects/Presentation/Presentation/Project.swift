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
    .Presentation(implements: .Auth),
    .Presentation(implements: .Splash),
    .Presentation(implements: .Management),
    .Presentation(implements: .Member),
    .Presentation(implements: .OnBoarding),
    .Presentation(implements: .Profile),
    .Presentation(implements: .Web)
  ],
  sources: ["Sources/**"]
)
