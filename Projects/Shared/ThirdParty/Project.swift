import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
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
    .SPM.collections,
    .SPM.swiftUIX,
    .SPM.fsCalendar,
    .SPM.firebaseAuth,
    .SPM.googleSignIn,
    .SPM.keychainAccess,
    .SPM.firebaseAuth,
    .SPM.firebaseFirestore,
    .SPM.firebaseAnalytics,
    .SPM.firebaseCrashlytics,
    .SPM.firebaseRemoteConfig,
    .SPM.firebaseDatabase,
  ],
  sources: ["Sources/**"]
)

