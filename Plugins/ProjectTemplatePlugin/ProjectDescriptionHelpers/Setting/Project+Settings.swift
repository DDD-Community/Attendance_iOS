//
//  Project+Settings.swift
//  MyPlugin
//
//  Created by 서원지 on 1/6/24.
//

import Foundation
import ProjectDescription

extension Settings {
  private static func commonSettings(
    appName: String,
    displayName: String,
    provisioningProfile: String,
    setSkipInstall: Bool
  ) -> SettingsDictionary {
    return SettingsDictionary()
      .setProductName(appName)
      .setCFBundleDisplayName(displayName)
      .setOtherLdFlags("-ObjC -all_load -w -Wl,-no_warn_unused_dylibs")
      .setDebugInformationFormat("dwarf-with-dsym")
      .setProvisioningProfileSpecifier(provisioningProfile)
      .setSkipInstall(setSkipInstall)
      .setCFBundleDevelopmentRegion("ko")
      .setSuppressAllWarnings()
  }

  private static func commonBaseSettings(
    appName: String
  ) -> SettingsDictionary {
    return SettingsDictionary()
      .setProductName(appName)
      .setOtherLdFlags("-ObjC -all_load -w -Wl,-no_warn_unused_dylibs")
      .setStripStyle()
      .setSuppressAllWarnings()
  }

  public static let appMainSetting: Settings = .settings(
    base: SettingsDictionary()
      .setProductName(Project.Environment.appName)
      .setCFBundleDisplayName(Project.Environment.appName)
      .setMarketingVersion(.appVersion())
      .setASAuthenticationServicesEnabled()
      .setPushNotificationsEnabled()
      .setEnableBackgroundModes()
      .setArchs()
      .setOtherLdFlags()
      .setCurrentProjectVersion(.appBuildVersion())
      .setCodeSignIdentity()
      .setCodeSignStyle()
      .setSwiftVersion("6.0")
      .setVersioningSystem()
      .setProvisioningProfileSpecifier("match Development \(Project.Environment.bundlePrefix)")
      .setDevelopmentTeam(Project.Environment.organizationTeamId)
      .setCFBundleDevelopmentRegion()
      .setDebugInformationFormat()
      .setSuppressAllWarnings(),
    configurations: [
      .debug(
        name: .debug,
        settings:
        commonSettings(
          appName: Project.Environment.appName,
          displayName: Project.Environment.appName,
          provisioningProfile: "match Development \(Project.Environment.bundlePrefix)",
          setSkipInstall: false
        ),
        xcconfig: .path(.dev)
      ),
      .debug(
        name: .stage,
        settings:
        commonSettings(
          appName: Project.Environment.appStageName,
          displayName: Project.Environment.appName,
          provisioningProfile: "match Development \(Project.Environment.bundlePrefix)",
          setSkipInstall: false
        ),
        xcconfig: .path(.stage)
      ),
      .release(
        name: .release,
        settings:
        commonSettings(
          appName: Project.Environment.appName,
          displayName: Project.Environment.appName,
          provisioningProfile: "match AppStore \(Project.Environment.bundlePrefix)",
          setSkipInstall: false
        ),
        xcconfig: .path(.release)
      ),
      .release(
        name: .prod,
        settings:
        commonSettings(
          appName: Project.Environment.appProdName,
          displayName: Project.Environment.appName,
          provisioningProfile: "match AppStore \(Project.Environment.bundlePrefix)",
          setSkipInstall: false
        ),
        xcconfig: .path(.prod)
      )

    ], defaultSettings: .recommended
  )

  public static func appBaseSetting(appName: String) -> Settings {
    let appBaseSetting: Settings = .settings(
      base: SettingsDictionary()
        .setProductName(appName)
        .setMarketingVersion(.appVersion())
        .setCurrentProjectVersion(.appBuildVersion())
        .setCodeSignIdentity()
        .setArchs()
        .setSwiftVersion("6.0")
        .setVersioningSystem()
        .setDebugInformationFormat()
        .setSuppressAllWarnings(),
      configurations: [
        .debug(
          name: .debug,
          settings:
          commonBaseSettings(
            appName: appName
          ),
          xcconfig:
          .relativeToRoot("./Config/dev.xcconfig")
        ),
        .debug(
          name: .stage,
          settings: commonBaseSettings(
            appName: appName
          ),
          xcconfig:
          .relativeToRoot("./Config/stage.xcconfig")
        ),
        .release(
          name: .release,
          settings: commonBaseSettings(
            appName: appName
          ),
          xcconfig: .relativeToRoot("./Config/release.xcconfig")
        )
      ], defaultSettings: .recommended
    )

    return appBaseSetting
  }
}

// MARK: - Settings Extensions

public extension Settings {
  /// 모듈 기본 설정 — 워크스페이스 표준 4 config(Debug/Stage/Prod/Release)를 부여한다.
  /// App 과 config 이름/타입이 일치해야 Stage/Prod config 빌드 시 의존성 그래프가 깨지지 않는다.
  static var moduleSettings: Settings {
    .settings(configurations: .moduleDefault)
  }

  static func repositoryBaseSettings() -> Settings {
    .settings(
      base: [
        "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
        "OTHER_SWIFT_FLAGS": "$(inherited) -suppress-warnings"
      ],
      configurations: .moduleDefault
    )
  }

  static func repositoryTestSettings() -> Settings {
    .settings(
      base: [
        "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
        "OTHER_SWIFT_FLAGS": "$(inherited) -suppress-warnings",
        "ENABLE_TESTING_SEARCH_PATHS": "YES",
        "SWIFT_TESTING": "YES"
      ],
      configurations: .moduleDefault
    )
  }
}
