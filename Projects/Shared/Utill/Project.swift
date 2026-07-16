import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
    name: "Utill",
    bundleId: .appBundleID(name: ".Utill"),
    product: .staticFramework,
    settings: .moduleSettings,
    dependencies: [
        .SPM.composableArchitecture,
    ],
    sources: ["Sources/**"]
)
