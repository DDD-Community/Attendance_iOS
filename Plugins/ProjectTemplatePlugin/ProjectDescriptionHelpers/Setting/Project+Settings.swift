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
      ),

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
      ], defaultSettings: .recommended)
    
    return appBaseSetting
    
  }
}
