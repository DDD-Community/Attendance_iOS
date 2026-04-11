// swift-tools-version: 6.1
@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
//    "AppAuth": .staticLibrary,
//    "AppAuthCore": .staticLibrary,
//    "GTMSessionFetcherCore": .staticLibrary,
    "ComposableArchitecture": .staticFramework,
    "TCAFlow": .staticFramework,
    "Moya": .staticFramework,
    "LogMacro": .staticFramework,
    "AsyncMoya": .staticFramework,
    "AppAuth": .staticFramework,
    "AppAuthCore": .staticFramework,
    "GTMAppAuth": .staticFramework,
    "GTMSessionFetcherCore": .staticFramework,
    "IssueReporting": .staticFramework,
    "IssueReportingPackageSupport": .staticFramework,
    "XCTestDynamicOverlay": .staticFramework,
    "Clocks": .staticFramework,
    "ConcurrencyExtras": .staticFramework,
    "SDWebImageSwiftUI": .staticFramework,
    "SwiftUIX": .staticFramework,
    "WeaveDI": .staticFramework
  ]
)
#endif
let package = Package(
  name: "DDDAttendance",
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.7.0"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.0.0"),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.25.5"),
    .package(url: "https://github.com/Roy-wonji/TCAFlow.git", branch: "main"),
    .package(url: "https://github.com/Roy-wonji/AsyncMoya",  from: "1.1.8"),
    .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", from: "0.2.3"),
    .package(url: "https://github.com/openid/AppAuth-iOS.git", from: "2.0.0"),
    .package(url: "https://github.com/Roy-wonji/WeaveDI.git", from: "3.4.0")
  ]
)
