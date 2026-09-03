import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "AppUpdateDomain",
  bundleId: .appBundleID(name: ".AppUpdateDomain"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [.core(.logger), .SPM.dependencies],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [.SPM.dependencies, .SPM.composableArchitecture]
)
