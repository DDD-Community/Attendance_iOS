import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
    name: "Networkings",
    bundleId: .appBundleID(name: ".Networkings"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        .Networking(implements: .API),
        .Networking(implements: .Service),
        .Networking(implements: .ThirdPartys),
        .Networking(implements: .Model),
        .Networking(implements: .DiContainer),
        .Networking(implements: .Foundations),
        .Networking(implements: .UseCase),
    ],
    sources: ["Sources/**"]
)
