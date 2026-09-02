import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let testHostSettings = Settings.settings(
  base: [
    // base.xcconfig의 정적 프레임워크용 레거시 ld 옵션은 Xcode 26 앱 링크에서 지원되지 않는다.
    "OTHER_LDFLAGS": "-w -Wl,-no_warn_unused_dylibs -dead_strip"
  ],
  configurations: XCConfig.configurations
)

func testHostTarget(
  name: String,
  dependencies: [TargetDependency] = []
) -> Target {
  return .target(
    name: name,
    destinations: Project.Environment.deploymentDestination,
    product: .app,
    bundleId: .appBundleID(name: ".\(name)"),
    deploymentTargets: Project.Environment.deploymentTarget,
    infoPlist: .default,
    buildableFolders: ["Sources"],
    dependencies: dependencies,
    settings: testHostSettings
  )
}

let project = Project(
  name: "DDDTestHost",
  options: .options(
    automaticSchemesOptions: .disabled,
    defaultKnownRegions: ["en", "ko"],
    developmentRegion: "ko"
  ),
  settings: .moduleSettings,
  targets: [
    // Swift Testing 번들도 Xcode test runner가 host bootstrap과 메타데이터 탐색을 수행한다.
    // 모든 모듈 테스트가 이 최소 Host를 공유하고, Xcode 26.3의 LocalStatusKit 충돌을
    // 피하도록 Sharing/SwiftUI를 테스트 번들보다 먼저 로드한다.
    testHostTarget(
      name: "DDDTestHost",
      dependencies: [.external(name: "ComposableArchitecture")]
    )
  ]
)
