import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
    name: "Shareds",
    bundleId: .appBundleID(name: ".Shareds"),
    product: .staticFramework,
    settings: .settings(),
    dependencies: [
        .Shared(implements: .ThirdParty),
        .Shared(implements: .Utill),
        .Shared(implements: .DesignSystem),
        .Data(implements: .Model),
    ],
    sources: ["Sources/**"]
)
