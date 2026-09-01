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

let project = Project(
  name: "DDDTestHost",
  options: .options(
    automaticSchemesOptions: .disabled,
    defaultKnownRegions: ["en", "ko"],
    developmentRegion: "ko"
  ),
  settings: .moduleSettings,
  targets: [
    .target(
      name: "DDDTestHost",
      destinations: Project.Environment.deploymentDestination,
      product: .app,
      bundleId: .appBundleID(name: ".DDDTestHost"),
      deploymentTargets: Project.Environment.deploymentTarget,
      infoPlist: .default,
      buildableFolders: ["Sources"],
      // Sharing/SwiftUI를 테스트 번들보다 먼저 앱 프로세스에서 로드해
      // Xcode 26.3의 host bootstrap 중 LocalStatusKit 충돌을 피한다.
      dependencies: [.external(name: "ComposableArchitecture")],
      settings: testHostSettings
    )
  ]
)
