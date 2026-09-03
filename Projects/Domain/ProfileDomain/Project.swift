import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "ProfileDomain",
  bundleId: .appBundleID(name: ".ProfileDomain"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .serviceAssembly,
    .domain(.auth, .interface),
    .domain(.onBoarding, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [.SPM.dependencies, .SPM.composableArchitecture]
)
