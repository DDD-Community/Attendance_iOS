//
//  Extension+TargetDependencySPM.swift
//  DependencyPackagePlugin
//
//  Created by 서원지 on 4/19/24.
//

import ProjectDescription

public extension TargetDependency.SPM {
  static let asyncMoya = TargetDependency.external(name: "AsyncMoya", condition: .none)
  static let logMarco = TargetDependency.external(name: "LogMarco", condition: .none)

  static let composableArchitecture = TargetDependency.external(name: "ComposableArchitecture", condition: .none)
  static let tcaFlow = TargetDependency.external(name: "TCAFlow", condition: .none)
  static let concurrencyExtras = TargetDependency.external(name: "ConcurrencyExtras", condition: .none)
  static let sdwebImage = TargetDependency.external(name: "SDWebImageSwiftUI", condition: .none)
  static let swiftUIX = TargetDependency.external(name: "SwiftUIX", condition: .none)
  static let weaveDI = TargetDependency.external(name: "WeaveDI", condition: .none)

  static let googleSignIn = TargetDependency.external(name: "GoogleSignIn", condition: .none)
  static let appAuth: TargetDependency = .external(name: "AppAuth")
  static let firebaseCrashlytics = TargetDependency.external(name: "FirebaseCrashlytics", condition: .none)
  static let firebaseMessaging = TargetDependency.external(name: "FirebaseMessaging", condition: .none)
  static let googleUtilities = TargetDependency.external(name: "GoogleUtilities", condition: .none)

}
