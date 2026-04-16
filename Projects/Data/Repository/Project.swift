import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project(
  name: "Repository",
  targets: [
    .target(
      name: "Repository",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: .appBundleID(name: ".Repository"),
      deploymentTargets: .iOS("18.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .Data(implements: .Service),
        .Data(implements: .Model),
        .Domain(implements: .DomainInterface),
        .Domain(implements: .Entity),
        .SPM.asyncMoya,
        .SPM.googleSignIn
      ]
    ),
    .target(
      name: "RepositoryTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: .appBundleID(name: ".RepositoryTests"),
      deploymentTargets: .iOS("18.0"),
      infoPlist: .default,
      sources: ["Tests/**"],
      dependencies: [
        .target(name: "Repository"),
        .Domain(implements: .DomainInterface),
        .Domain(implements: .Entity)
      ]
    )
  ]
)
