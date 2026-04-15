//
//  Project+Template.swift
//  MyPlugin
//
//  Created by 서원지 on 1/6/24.
//

import ProjectDescription

// MARK: - Suppress Warnings Setting
private let suppressWarningsSettings: ProjectDescription.Settings = .settings(
  base: [
    // Swift 컴파일러 경고 억제
    "OTHER_SWIFT_FLAGS": SettingValue(stringLiteral: "$(inherited) -suppress-warnings -Xfrontend -warn-concurrency"),

    // 링커 플래그 - "has no symbols" 경고 억제 (호환성 개선)
    "OTHER_LDFLAGS": SettingValue(stringLiteral: [
      "$(inherited)",
      "-w",
      "-Wl,-no_warn_unused_dylibs",
      "-dead_strip"
    ].joined(separator: " ")),

    // 링커 경고 설정
    "LD_NO_WARN_UNUSED_DYLIBS": SettingValue(stringLiteral: "YES"),
    "LD_WARN_UNUSED_DYLIBS": SettingValue(stringLiteral: "NO"),
    "LINKER_DISPLAYS_MANGLED_NAMES": SettingValue(stringLiteral: "NO"),

    // 컴파일러 경고 설정
    "WARNING_CFLAGS": SettingValue(stringLiteral: "-w"),
    "GCC_WARN_INHIBIT_ALL_WARNINGS": SettingValue(stringLiteral: "YES"),
    "CLANG_WARN_EVERYTHING": SettingValue(stringLiteral: "NO"),
    "CLANG_WARN_EMPTY_BODY": SettingValue(stringLiteral: "NO"),

    // Swift 6 관련 설정
    "SWIFT_STRICT_CONCURRENCY": SettingValue(stringLiteral: "minimal"),
    "SWIFT_UPCOMING_FEATURE_CONCISE_MAGIC_FILE": SettingValue(stringLiteral: "YES"),
    "SWIFT_SUPPRESS_WARNINGS": SettingValue(stringLiteral: "YES"),

    // 빌드 최적화
    "DEAD_CODE_STRIPPING": SettingValue(stringLiteral: "YES"),
    "PRESERVE_DEAD_CODE_INITS_AND_TERMS": SettingValue(stringLiteral: "NO"),

    // 아키텍처 관련
    "ONLY_ACTIVE_ARCH": SettingValue(stringLiteral: "NO"),

    // 디버그 정보 최적화
    "DEBUG_INFORMATION_FORMAT": SettingValue(stringLiteral: "dwarf"),

    // 모듈 관련 설정
    "DEFINES_MODULE": SettingValue(stringLiteral: "YES"),
    "CLANG_ENABLE_MODULES": SettingValue(stringLiteral: "YES")
  ]
)

public extension Project {
  static func makeAppModule(
    name: String = Environment.appName,
    bundleId: String,
    platform: Platform = .iOS,
    product: Product,
    packages: [Package] = [],
    deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
    destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
    settings: ProjectDescription.Settings,
    scripts: [ProjectDescription.TargetScript] = [],
    dependencies: [ProjectDescription.TargetDependency] = [],
    sources: ProjectDescription.SourceFilesList = ["Sources/**"],
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
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: suppressWarningsSettings
    )

    let appProdTarget: Target = .target(
      name: "\(name)-Prod",
      destinations: destinations,
      product: product,
      bundleId: "\(bundleId)",
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: suppressWarningsSettings
    )


    let appStageTarget: Target = .target(
      name: "\(name)-Stage",
      destinations: destinations,
      product: product,
      bundleId: "\(bundleId)",
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: suppressWarningsSettings
    )


    let appDevTarget: Target = .target(
      name: "\(name)-Debug",
      destinations: destinations,
      product: product,
      bundleId: "\(bundleId)",
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: suppressWarningsSettings
    )

    var targets: [Target] = [appTarget, appDevTarget, appStageTarget, appProdTarget]

    if hasTests {
        let appTestTarget : Target = .target(
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
      schemes: schemes
    )
  }

  static func makeModule(
    name: String = Environment.appName,
    bundleId: String,
    platform: Platform = .iOS,
    product: Product,
    packages: [Package] = [],
    deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
    destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
    settings: ProjectDescription.Settings,
    scripts: [ProjectDescription.TargetScript] = [],
    dependencies: [ProjectDescription.TargetDependency] = [],
    sources: ProjectDescription.SourceFilesList = ["Sources/**"],
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
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: suppressWarningsSettings
    )

    var targets: [Target] = [appTarget]

    if hasTests {
      let appTestTarget : Target = .target(
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
      schemes: schemes
    )
  }
}



extension Scheme {
  public static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
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
