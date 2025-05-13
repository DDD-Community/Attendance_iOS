//
//  Project+InfoPlist.swift
//  Plugins
//
//  Created by Wonji Suh  on 3/22/25.
//

import Foundation
import ProjectDescription

public extension InfoPlist {
  static let appInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundleName("DDD 출석")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setAppTransportSecurity()
      .setCFBundleURLTypes()
      .setAppUseExemptEncryption(value: false)
      .setCFBundleVersion(.appBuildVersion())
      .setLSRequiresIPhoneOS(true)
      .setUIAppFonts(["PretendardVariable.ttf"])
      .setUIApplicationSceneManifest([
        "UIApplicationSupportsMultipleScenes": true,
        "UISceneConfigurations": [
          "UIWindowSceneSessionRoleApplication": [
            [
              "UISceneConfigurationName": "Default Configuration",
            ]
          ]
        ]
      ])
      .setUIRequiredDeviceCapabilities(["armv7"])
      .setUISupportedInterfaceOrientations(["UIInterfaceOrientationPortrait"])
      .setNSCameraUsageDescription("QR 코드 인식을 위해 카메라 접근 권한이 필요합니다")
      .setUILaunchScreens()
      .setCalenderUsage("캘린더의 정보를 가져오기 위해서 접근 권한을 허용해주세요")
      .setCFBundleDevelopmentRegion()
      .setGoogleReversedClientID("${REVERSED_CLIENT_ID}")
      .setGoogleClientID("${GOOGLE_CLIENT_ID}")
      .setGIDClientID("${GOOGLE_CLIENT_ID}")
      .setBaseURL("$(BASE_URL)")
  )
  
  static let moduleInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setBaseURL("$(BASE_URL)")
  )
}
