//
//  Project+Template.swift
//  MyPlugin
//
//  Created by DDD on 1/6/24.
//

import ProjectDescription

// MARK: - Suppress Warnings Setting

private let suppressWarningsSettings: ProjectDescription.Settings = .settings(
  base: ["OTHER_SWIFT_FLAGS": "$(inherited) -suppress-warnings"]
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
    // 예전에는 -Debug/-Stage/-Prod 타깃을 복제했지만, 네 타깃이 name 만 다르고
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
      // 프로젝트 config 이름은 Debug/Stage/Prod/Release (Dev.xcconfig 는 Debug config 에 연결됨).
      envScheme(name, config: .release),
      envScheme("\(name)-Debug", config: .debug),
      envScheme("\(name)-Stage", config: .stage),
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

public extension Scheme {
  static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
    return Scheme.scheme(
      name: name,
      shared: true,
      buildAction: .buildAction(targets: ["\(name)"]),
      testAction: .targets(
        ["\(name)Tests"],
        configuration: target,
        options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
      ),
      runAction: .runAction(configuration: target),
      archiveAction: .archiveAction(configuration: target),
      profileAction: .profileAction(configuration: target),
      analyzeAction: .analyzeAction(configuration: target)
    )
  }
}

public extension Scheme {
  static func scheme(name: String, environment: ConfigurationEnvironment) -> Scheme {
    let appName = Project.Environment.appName
    let schemeName = switch environment {
    case .prod: appName
    case .dev, .stage: "\(appName)-\(environment.name)"
    }

    return .scheme(
      name: schemeName,
      buildAction: .buildAction(targets: [.target(name)]),
      runAction: .runAction(configuration: .init(stringLiteral: environment.name)),
      archiveAction: .archiveAction(configuration: .release),
      profileAction: .profileAction(configuration: .release),
      analyzeAction: .analyzeAction(configuration: .debug)
    )
  }
}
