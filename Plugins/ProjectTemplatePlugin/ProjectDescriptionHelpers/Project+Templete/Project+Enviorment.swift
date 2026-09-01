//
//  Project+Enviorment.swift
//  MyPlugin
//
//  Created by DDD on 1/6/24.
//

import Foundation
import ProjectDescription

public extension Project {
  enum Environment {
    public static let appName = "DDDAttendance"
    public static let appStageName = "DDDAttendance-Stage"
    public static let appProdName = "DDDAttendance-Prod"
    public static let deploymentTarget : ProjectDescription.DeploymentTargets = .iOS("17.0")
    public static let deploymentDestination: ProjectDescription.Destinations = [.iPhone]
    public static let organizationTeamId = "N94CS4N6VR"
    public static let bundlePrefix = "io.DDD.Attendance"
    public static let appVersion = "1.0.0"
    public static let mainBundleId = "io.DDD.Attendance"
  }
}
