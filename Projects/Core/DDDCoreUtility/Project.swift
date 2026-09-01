import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
    name: "DDDCoreUtility",
    bundleId: .appBundleID(name: ".DDDCoreUtility"),
    product: .staticFramework,
    settings: .moduleSettings,
    dependencies: [
        .SPM.composableArchitecture,
    ],
    sources: ["Sources/**"],
    hasTests: true
)
