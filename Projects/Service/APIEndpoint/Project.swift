import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "APIEndpoint",
  bundleId: .appBundleID(name: ".APIEndpoint"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .core(.network, .interface),
    .service(.api),
    .domain(.entity),
    .SPM.alamofire
  ],
  sources: ["Sources/**"],
  hasTests: true
)
