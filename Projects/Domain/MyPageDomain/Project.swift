import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "MyPageDomain",
  bundleId: .appBundleID(name: ".MyPageDomain"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .serviceAssembly,
    .SPM.dependencies
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [.SPM.dependencies, .SPM.composableArchitecture]
)
