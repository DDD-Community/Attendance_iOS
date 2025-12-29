import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Presentation",
  bundleId: .appBundleID(name: ".Presentation"),
  product: Project.Environment.presentationProduct,
  settings:  .settings(),
  dependencies: [
    .Shared(implements: .Shareds),
    .Core(implements: .Core),
    .Presentation(implements: .Auth),
    .Presentation(implements: .Splash),
    .Presentation(implements: .Management),
    .Presentation(implements: .Member),


  ],
  sources: ["Sources/**"]
)
