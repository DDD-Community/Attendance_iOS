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
  ]
  // Picke-iOS처럼 baseSettings 미지정 — SPM 패키지에 Prod/Stage 커스텀 config를 만들지 않아야
  // Prod scheme archive 시 매크로(CasePathsMacrosSupport) 빌드가 정상 동작한다.
)
#endif
let package = Package(
  name: "DDDAttendance",
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "12.12.0"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", exact: "9.1.0"),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", exact: "3.1.4"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.25.5"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
    .package(url: "https://github.com/Roy-wonji/TCAFlow.git", exact: "1.1.2"),
    .package(url: "https://github.com/Roy-wonji/AsyncMoya", exact: "1.1.8"),
    .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", exact: "0.2.3"),
    .package(url: "https://github.com/openid/AppAuth-iOS.git", exact: "2.0.0"),
    .package(url: "https://github.com/Roy-wonji/WeaveDI.git", exact: "3.4.1")
  ]
)
