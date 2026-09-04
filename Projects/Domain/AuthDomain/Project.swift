import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "AuthDomain",
  bundleId: .appBundleID(name: ".AuthDomain"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .serviceAssembly,
    .domain(.onBoarding, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture,
    .SPM.googleSignIn
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .core(.storage, .interface),
    .domain(.profile, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture,
    .SPM.sharing
  ]
)
