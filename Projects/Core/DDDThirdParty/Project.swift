import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDThirdParty",
  bundleId: .appBundleID(name: ".DDDThirdParty"),
  product: Project.Environment.sharedProduct,
  settings: .moduleSettings,
  dependencies: [
    .SPM.asyncMoya,
    .SPM.composableArchitecture,
    .SPM.concurrencyExtras,
    .SPM.tcaFlow,
    .SPM.sdwebImage,
    .SPM.swiftUIX,
    .SPM.googleSignIn,
    .SPM.firebaseCrashlytics,
    .SPM.weaveDI,
  ],
  sources: ["Sources/**"]
)
