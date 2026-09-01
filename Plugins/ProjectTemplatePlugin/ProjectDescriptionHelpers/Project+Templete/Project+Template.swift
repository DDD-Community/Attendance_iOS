//
//  Project+Template.swift
//  MyPlugin
//
//  Created by DDD on 1/6/24.
//

import ProjectDescription

// MARK: - Suppress Warnings Setting

private let suppressWarningsSettings: ProjectDescription.Settings = .settings(
  base: [
    // Xcode 26의 ld가 제거한 -no_warn_empty_source_files/-no_warn_no_symbols를
    // 오래된 xcconfig에서 상속하지 않도록 타깃 수준에서 안전한 플래그만 사용한다.
    "OTHER_LDFLAGS": "-w -Wl,-no_warn_unused_dylibs -dead_strip",
    "OTHER_SWIFT_FLAGS": "$(inherited) -suppress-warnings"
  ],
  configurations: XCConfig.configurations
)

public extension Project {
  static func makeAppModule(
    name: String = Environment.appName,
    bundleId: String,
    platform _: Platform = .iOS,
    product: Product,
    packages: [Package] = [],
    deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
    destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
    settings: ProjectDescription.Settings,
    scripts: [ProjectDescription.TargetScript] = [],
    dependencies: [ProjectDescription.TargetDependency] = [],
    sources _: ProjectDescription.SourceFilesList = ["Sources/**"],
    resources: ProjectDescription.ResourceFileElements? = nil,
    infoPlist: ProjectDescription.InfoPlist = .default,
    entitlements: ProjectDescription.Entitlements? = nil,
    schemes: [ProjectDescription.Scheme] = [],
    hasTests: Bool = false
  ) -> Project {
    let appTarget: Target = .target(
      name: name,
      destinations: destinations,
      product: product,
      bundleId: bundleId,
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      buildableFolders: resources != nil ? ["Sources", "Resources"] : ["Sources"],
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: suppressWarningsSettings
    )

    // 단일 타깃 + 다중 config 구조.
    // 예전에는 환경별 타깃을 복제했지만, 타깃은 name 만 다르고
    // 나머지가 전부 동일해 불필요했다. 환경 분기는 config(xcconfig)와 스킴으로만 한다.
    var targets: [Target] = [appTarget]

    if hasTests {
      let appTestTarget: Target = .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleId).\(name)Tests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        buildableFolders: ["Tests"],
        dependencies: [.target(name: name)],
        settings: suppressWarningsSettings
      )
      targets.append(appTestTarget)
    }

    return Project(
      name: name,
      options: .options(
        automaticSchemesOptions: .enabled(codeCoverageEnabled: true),
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
      ),
      packages: packages,
      settings: settings,
      targets: targets,
      schemes: schemes.isEmpty ? appEnvironmentSchemes(name: name) : schemes,
      fileHeaderTemplate: .default
    )
  }

  /// 단일 앱 타깃을 환경별 config 로 빌드하는 스킴들.
  /// 스킴 이름은 기존 CI(fastlane STAGE_SCHEME/PROD_SCHEME)와 호환되도록 유지한다.
  private static func appEnvironmentSchemes(name: String) -> [Scheme] {
    func envScheme(_ schemeName: String, config: ConfigurationName) -> Scheme {
      return .scheme(
        name: schemeName,
        shared: true,
        buildAction: .buildAction(
          targets: [.target(name)],
          postActions: [
            .executionAction(
              title: "Inspect Build",
              scriptText: "$HOME/.local/bin/mise x -C $SRCROOT -- tuist inspect build",
              target: .target(name)
            )
          ],
          runPostActionsOnFailure: true
        ),
        runAction: .runAction(configuration: config),
        archiveAction: .archiveAction(configuration: config),
        profileAction: .profileAction(configuration: config),
        analyzeAction: .analyzeAction(configuration: config)
      )
    }
    return [
      // Stage 는 여러 프로젝트의 테스트를 포함해야 하므로 WorkSpace.swift 에서 정의한다.
      // 앱 프로젝트에는 배포용 Prod 스킴만 둬 같은 이름의 Stage 스킴 충돌을 막는다.
      envScheme("\(name)-Prod", config: .prod)
    ]
  }

  static func makeModule(
    name: String = Environment.appName,
    bundleId: String,
    platform _: Platform = .iOS,
    product: Product,
    packages: [Package] = [],
    deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
    destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
    settings: ProjectDescription.Settings,
    scripts: [ProjectDescription.TargetScript] = [],
    dependencies: [ProjectDescription.TargetDependency] = [],
    sources _: ProjectDescription.SourceFilesList = ["Sources/**"],
    resources: ProjectDescription.ResourceFileElements? = nil,
    infoPlist: ProjectDescription.InfoPlist = .default,
    entitlements: ProjectDescription.Entitlements? = nil,
    schemes: [ProjectDescription.Scheme] = [],
    hasTests: Bool = false,
    hasInterface: Bool = false,
    interfaceDependencies: [ProjectDescription.TargetDependency] = [],
    hasTesting: Bool = false
  ) -> Project {
    // Interface 타깃은 Interface/ 폴더가 실제로 있을 때만 만든다(buildableFolders 는 폴더가 없으면 generate 실패).
    let interfaceTarget: Target? = hasInterface ? .target(
      name: "\(name)Interface",
      destinations: destinations,
      product: product,
      bundleId: "\(bundleId)Interface",
      deploymentTargets: deploymentTarget,
      infoPlist: .default,
      buildableFolders: ["Interface"],
      dependencies: interfaceDependencies,
      settings: suppressWarningsSettings
    ) : nil

    let appTarget: Target = .target(
      name: name,
      destinations: destinations,
      product: product,
      bundleId: bundleId,
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      buildableFolders: resources != nil ? ["Sources", "Resources"] : ["Sources"],
      entitlements: entitlements,
      scripts: scripts,
      // 구현은 자기 Interface 를 항상 의존한다.
      dependencies: (hasInterface ? [.target(name: "\(name)Interface")] : []) + dependencies,
      settings: suppressWarningsSettings
    )

    var targets: [Target] = interfaceTarget.map { [$0, appTarget] } ?? [appTarget]

    // Testing: Interface 를 구현한 목/더블. 구현이 아니라 Interface 에만 의존해야
    // 다른 모듈 테스트가 구현을 끌고 오지 않고 재사용할 수 있다.
    if hasTesting {
      targets.append(.target(
        name: "\(name)Testing",
        destinations: destinations,
        product: product,
        bundleId: "\(bundleId)Testing",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        buildableFolders: ["Testing"],
        dependencies: hasInterface ? [.target(name: "\(name)Interface")] : [.target(name: name)],
        settings: suppressWarningsSettings
      ))
    }

    if hasTests {
      let appTestTarget: Target = .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleId).\(name)Tests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        buildableFolders: ["Tests"],
        // Testing 이 있으면 테스트가 그 목을 그대로 쓴다.
        dependencies: [.target(name: name)] + (hasTesting ? [.target(name: "\(name)Testing")] : []),
        settings: suppressWarningsSettings
      )
      targets.append(appTestTarget)
    }

    return Project(
      name: name,
      // tuist test 는 모듈별 자동 생성 스킴으로 도는데, 여기서 커버리지를 켜지 않으면
      // 결과 번들에 커버리지가 담기지 않아 리포트가 비어 나온다.
      options: .options(
        automaticSchemesOptions: .enabled(codeCoverageEnabled: true),
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
      ),
      packages: packages,
      settings: settings,
      targets: targets,
      schemes: schemes,
      fileHeaderTemplate: .default
    )
  }
}
