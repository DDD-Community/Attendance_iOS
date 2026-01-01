// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    "FirebaseCore": .staticLibrary,
    "FirebaseAuth": .staticLibrary,
    "FirebaseFirestore": .staticLibrary,
    "FirebaseAnalytics": .staticLibrary,
    "FirebaseCrashlytics": .staticLibrary,
    "FirebaseRemoteConfig": .staticLibrary
  ]
)
#endif
let package = Package(
  name: "DDDAttendance",
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.7.0"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.0.0"),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0"),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
    .package(url: "https://github.com/exyte/PopupView.git", from: "2.10.4"),
    .package(url: "http://github.com/pointfreeco/swift-composable-architecture", exact: "1.18.0"),
    .package(url: "https://github.com/pointfreeco/swift-concurrency-extras.git", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-collections.git", branch: "main"),
    .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators.git", exact: "0.11.1"),
    .package(url: "https://github.com/Roy-wonji/AsyncMoya",  from: "1.1.8"),
    .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", from: "0.2.3"),
    .package(url: "https://github.com/WenchaoD/FSCalendar.git", from: "2.8.3"),
    .package(url: "https://github.com/openid/AppAuth-iOS.git", from: "2.0.0"),
    .package(url: "https://github.com/Roy-wonji/WeaveDI.git", branch: "main")
  ]
)
