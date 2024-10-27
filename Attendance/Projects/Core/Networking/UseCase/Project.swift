import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
name: "UseCase",
bundleId: .appBundleID(name: ".UseCase"),
product: .staticFramework,
settings:  .settings(),
dependencies: [

],
sources: ["Sources/**"]
)
