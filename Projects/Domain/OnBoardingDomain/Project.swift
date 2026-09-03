import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "OnBoardingDomain",
  bundleId: .appBundleID(name: ".OnBoardingDomain"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .serviceAssembly,
    .domain(.auth),
    .SPM.dependencies
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .domain(.auth, .interface),
    .domain(.profile, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture
  ]
)
