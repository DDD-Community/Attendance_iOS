import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "ThirdParty",
  bundleId: .appBundleID(name: ".ThirdParty"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
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
    .SPM.firebaseAnalytics,
    .SPM.firebaseCrashlytics,
    .SPM.firebaseRemoteConfig,
  ],
  sources: ["Sources/**"]
)

