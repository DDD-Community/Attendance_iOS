// swift-tools-version: 6.2
@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    // Firebase 체인은 통째로 동적 프레임워크로 올린다.
    // 앱에 .framework 모듈(DDDDesignKit)이 있으면 정적 산출물이 그 경계에서 흡수돼
    // 앱 링크 라인까지 전파되지 않는다. 일부만 올리면 nanopb/FirebaseSessions 심볼이 풀리지 않아
    // 체인 전체를 함께 올려야 한다.
    // 키는 패키지 이름이 아니라 SPM 타깃 이름이다 ("GoogleUtilities" 같은 패키지 이름은 매칭되지 않는다).
    "Firebase": .framework,
    "FirebaseCore": .framework,
    "FirebaseCoreExtension": .framework,
    "FirebaseCoreInternal": .framework,
    "FirebaseInstallations": .framework,
    "FirebaseSessions": .framework,
    "FirebaseSessionsObjC": .framework,
    "FirebaseCrashlytics": .framework,
    "FirebaseCrashlyticsSwift": .framework,
    "FirebaseRemoteConfigInterop": .framework,
    "FirebaseAppCheck": .framework,
    "FirebaseAppCheckInterop": .framework,
    "GoogleDataTransport": .framework,
    "nanopb": .framework,
    "AppCheckCore": .framework,
    "FBLPromises": .framework,
    "Promises": .framework,
    "GoogleUtilities-AppDelegateSwizzler": .framework,
    "GoogleUtilities-Environment": .framework,
    "GoogleUtilities-Logger": .framework,
    "GoogleUtilities-MethodSwizzler": .framework,
    "GoogleUtilities-Network": .framework,
    "GoogleUtilities-NSData": .framework,
    "GoogleUtilities-Reachability": .framework,
    "GoogleUtilities-UserDefaults": .framework,

    // 기존 설정 유지
    "Moya": .staticFramework,
    "LogMacro": .staticFramework,
    "AsyncMoya": .staticFramework,
    "AppAuth": .staticFramework,
    "AppAuthCore": .staticFramework,
    "GTMAppAuth": .staticFramework,
    "GTMSessionFetcherCore": .staticFramework,
    
    "ComposableArchitecture": .framework,
    "IdentifiedCollections": .framework,
    "TCAFlow": .framework,
    "IssueReporting": .framework,
    "IssueReportingPackageSupport": .framework,
    "XCTestDynamicOverlay": .framework,
    "Clocks": .framework,
    "CombineSchedulers": .framework,
    "ConcurrencyExtras": .framework,
    "SDWebImageSwiftUI": .framework,
    "SDWebImage": .framework,
    "SwiftUIX": .framework,
    
    // ── 경고에 떴지만 productTypes에 없어서 기본값(static)으로 중복되던 전이 의존성 ──
    "Dependencies": .framework,
    "DependenciesMacros": .framework,
    "PerceptionCore": .framework,
    "Perception": .framework,
    "Sharing": .framework,
    "SwiftNavigation": .framework,
    "SwiftUINavigation": .framework,
    "CasePaths": .framework,
    "Alamofire": .framework,
    
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
    .package(url: "https://github.com/Alamofire/Alamofire", exact: "5.12.0"),
  ]
)
