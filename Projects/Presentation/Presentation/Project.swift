import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "Presentation",
  bundleId: .appBundleID(name: ".Presentation"),
  product: .staticFramework,
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
