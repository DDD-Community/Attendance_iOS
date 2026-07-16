import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "ThirdParty",
  bundleId: .appBundleID(name: ".ThirdParty"),
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
