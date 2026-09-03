import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "QRCodeDomain",
  bundleId: .appBundleID(name: ".QRCodeDomain"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .serviceAssembly,
    .domain(.attendance, .interface),
    .domain(.onBoarding, .interface),
    .SPM.dependencies
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .domain(.attendance, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture
  ]
)
