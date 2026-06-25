// swift-tools-version: 6.2
@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    // Firebase 관련 패키지들을 정적 프레임워크로 설정
    "FirebaseCore": .staticFramework,
    "FirebaseCoreExtension": .staticFramework,
    "FirebaseAppCheck": .staticFramework,
    "FirebaseAppCheckInterop": .staticFramework,
    "AppCheckCore": .staticFramework,
    "GoogleUtilities": .staticFramework,
    "nanopb": .staticFramework,
    "PromisesObjC": .staticFramework,

    // 기존 설정 유지
    "ComposableArchitecture": .staticFramework,
    "IdentifiedCollections": .staticFramework,
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
    // Picke 스타일에 맞춰 정적 프레임워크로 통일 (archive 시 strip 노이즈 제거)
    "Clocks": .staticFramework,
    "CombineSchedulers": .staticFramework,
    "ConcurrencyExtras": .staticFramework,
    "SDWebImageSwiftUI": .staticFramework,
    "SDWebImage": .staticFramework,
    "SwiftUIX": .staticFramework,
    "WeaveDI": .staticFramework,

    // GoogleSignIn 관련
    "GoogleSignIn": .staticFramework,
    "GoogleSignInSwift": .staticFramework,
    "GTMSessionFetcher": .staticFramework
  ],
  baseSettings: .settings(
    base: [
      // Xcode 26 explicit modules가 매크로 플러그인(LogMacroMacro 등)을 incompatible target으로
      // 빌드하는 문제 회피 — 모든 SPM 매크로를 implicit 방식으로 빌드
      "SWIFT_ENABLE_EXPLICIT_MODULES": "NO"
    ],
    configurations: [
      .debug(name: "Debug"),
      .debug(name: "Stage"),
      .release(name: "Release"),
      .release(name: "Prod")
    ]
  )
)
#endif
let package = Package(
  name: "DDDAttendance",
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "12.12.0"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", exact: "9.1.0"),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", exact: "3.1.4"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.25.5"),
    // swift-case-paths 1.7.3은 Xcode 26 archive에서 CasePathsMacrosSupport 모듈 빌드 실패 →
    // Picke-iOS와 동일하게 1.7.2로 핀 (정상 빌드 버전)
    .package(url: "https://github.com/pointfreeco/swift-case-paths", exact: "1.7.2"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
    .package(url: "https://github.com/Roy-wonji/TCAFlow.git", exact: "1.1.2"),
    .package(url: "https://github.com/Roy-wonji/AsyncMoya", exact: "1.1.8"),
    .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", exact: "0.2.3"),
    .package(url: "https://github.com/openid/AppAuth-iOS.git", exact: "2.0.0"),
    .package(url: "https://github.com/Roy-wonji/WeaveDI.git", exact: "3.4.1")
  ]
)
