import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Repository",
  bundleId: .appBundleID(name: ".Repository"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Data(implements: .Service),
    .Domain(implements: .DomainInterface),

      .SPM.googleSignIn
  ],
  sources: ["Sources/**"],
  hasTests: true
)
