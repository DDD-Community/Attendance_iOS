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
        sources: ["Tests/Sources/**"],
        dependencies: [.target(name: name)],
        settings: suppressWarningsSettings
      )
      targets.append(appTestTarget)
    }

    return Project(
      name: name,
      options: .options(
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
      .scheme(
        name: schemeName,
        shared: true,
        buildAction: .buildAction(targets: [.target(name)]),
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
    interfaceDependencies: [ProjectDescription.TargetDependency] = []
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

    if hasTests {
      let appTestTarget: Target = .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleId).\(name)Tests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        sources: ["Tests/Sources/**"],
        dependencies: [.target(name: name)],
        settings: suppressWarningsSettings
      )
      targets.append(appTestTarget)
    }

    return Project(
      name: name,
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
