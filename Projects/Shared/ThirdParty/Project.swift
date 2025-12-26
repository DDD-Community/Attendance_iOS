import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "ThirdParty",
  bundleId: .appBundleID(name: ".ThirdParty"),
  product: Project.Environment.sharedProduct,
  settings: .settings(),
  dependencies: [
    .SPM.asyncMoya,
    .SPM.composableArchitecture,
    .SPM.concurrencyExtras,
    .SPM.tcaCoordinator,
    .SPM.sdwebImage,
    .SPM.collections,
    .SPM.popupView,
    .SPM.swiftUIX,
    .SPM.fsCalendar,
    .SPM.googleSignIn,
    .SPM.keychainAccess,
    .SPM.firebaseAuth,
    .SPM.firebaseFirestore,
    .SPM.firebaseCore,
    .SPM.firebaseAnalytics,
    .SPM.firebaseCrashlytics,
    .SPM.firebaseRemoteConfig,
    .SPM.weaveDI,
  ],
  sources: ["Sources/**"]
)
