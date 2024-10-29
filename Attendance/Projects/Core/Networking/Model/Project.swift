import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
    name: "Model",
    bundleId: .appBundleID(name: ".Model"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        
    ],
    sources: ["Sources/**"]
)
