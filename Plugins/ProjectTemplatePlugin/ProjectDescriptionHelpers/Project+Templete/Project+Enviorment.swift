//
//  Project+Enviorment.swift
//  MyPlugin
//
//  Created by 서원지 on 1/6/24.
//

import Foundation
import ProjectDescription

public extension Project {
  enum Environment {
    public static let appName = "DDDAttendance"
    public static let appStageName = "DDDAttendance-Stage"
    public static let appProdName = "DDDAttendance-Prod"
    public static let appDevName = "DDDAttendance-Dev"
    public static let deploymentTarget : ProjectDescription.DeploymentTargets = .iOS("17.0")
    public static let deploymentDestination: ProjectDescription.Destinations = [.iPhone]
    public static let organizationTeamId = "N94CS4N6VR"
    public static let bundlePrefix = "io.DDD.Attendance"
    public static let appVersion = "1.0.0"
    public static let mainBundleId = "io.DDD.Attendance"
    public static let presentationProduct: ProjectDescription.Product = {
      let forPreview = ProcessInfo.processInfo.environment["TUIST_FOR_PREVIEW"]?.lowercased() == "true"
      let linking = ProcessInfo.processInfo.environment["TUIST_LINKING"]?.lowercased()
      let isRelease = ProcessInfo.processInfo.environment["TUIST_BUILD_TYPE"]?.lowercased() == "release"

      // Release 빌드시에는 무조건 staticFramework
      if isRelease {
        return .staticFramework
      }

      // Debug/Development에서는 Preview 지원
      return forPreview || linking == "dynamic" ? .framework : .staticFramework
    }()

    // 공유 라이브러리용 Product 타입 (ThirdParty, DesignSystem 등)
    public static let sharedProduct: ProjectDescription.Product = {
      let forPreview = ProcessInfo.processInfo.environment["TUIST_FOR_PREVIEW"]?.lowercased() == "true"
      let linking = ProcessInfo.processInfo.environment["TUIST_LINKING"]?.lowercased()
      let isRelease = ProcessInfo.processInfo.environment["TUIST_BUILD_TYPE"]?.lowercased() == "release"

      // Release 빌드시에는 무조건 staticFramework
      if isRelease {
        return .staticFramework
      }

      // Preview 모드에서는 중복 링킹 문제 방지를 위해 framework 사용
      return forPreview || linking == "dynamic" ? .framework : .staticFramework
    }()
  }
}
