//
//  Tuist.swift
//  Manifests
//
//  Created by DDD on 2/4/25.
//

import ProjectDescription
import Foundation

let tuist = Tuist(
  fullHandle:  "DDD/attendance",
  project: .tuist(
    compatibleXcodeVersions: .all,
    swiftVersion: .some("6.0.0"),
    plugins: [
      .local(path: .relativeToRoot("Plugins/ProjectTemplatePlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPackagePlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPlugin")),
    ],
    generationOptions: .options(
      optionalAuthentication: true,
      disableSandbox: true
    ),
    installOptions: .options()
  )
)
