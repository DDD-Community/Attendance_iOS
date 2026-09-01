// swift-tools-version: 6.2
@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    // 여러 모듈이 공유하는 저수준 의존은 동적 프레임워크로 둔다.
    // GoogleUtilities 는 단일 프로덕트가 아니라 서브프로덕트로 나뉘어 있어
    // 이름을 개별로 적어야 설정이 먹는다 ("GoogleUtilities" 키는 매칭되지 않는다).
    "GoogleUtilities-AppDelegateSwizzler": .framework,
    "GoogleUtilities-Environment": .framework,
    "GoogleUtilities-Logger": .framework,
    "GoogleUtilities-MethodSwizzler": .framework,
    "GoogleUtilities-Network": .framework,
    "GoogleUtilities-NSData": .framework,
    "GoogleUtilities-Reachability": .framework,
    "GoogleUtilities-UserDefaults": .framework,
    "FBLPromises": .framework,
    "nanopb": .framework,
    "FirebaseCore": .framework,
    "FirebaseCoreInternal": .framework,
    "FirebaseInstallations": .framework,

    // Firebase 리프 제품은 정적 유지
    "FirebaseCoreExtension": .staticFramework,
    "FirebaseAppCheck": .staticFramework,
    "FirebaseAppCheckInterop": .staticFramework,
    "AppCheckCore": .staticFramework,

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

    // GoogleSignIn 관련
    "GoogleSignIn": .staticFramework,
    "GoogleSignInSwift": .staticFramework,
    "GTMSessionFetcher": .staticFramework
  ],
  baseSettings: .settings(
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
    .package(url: "https://github.com/pointfreeco/swift-case-paths", exact: "1.7.2"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
    .package(url: "https://github.com/Roy-wonji/TCAFlow.git", exact: "1.1.3"),
    .package(url: "https://github.com/Roy-wonji/AsyncMoya", exact: "1.1.8"),
    .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", exact: "0.2.3"),
    .package(url: "https://github.com/openid/AppAuth-iOS.git", exact: "2.0.0"),
  ]
)
