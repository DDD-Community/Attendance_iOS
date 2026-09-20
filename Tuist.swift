//
//  Tuist.swift
//  Manifests
//
//  Created by DDD on 2/4/25.
//

import Foundation
import ProjectDescription

let tuist = Tuist(
  fullHandle: "DDD2026/attendance",
  xcodeCache: .xcodeCache(
    upload: Environment.isCI
  ),
  // 캐시 업로드는 CI 에서만 한다. 로컬은 읽기 전용으로 두어 개발 중 업로드 비용을 없앤다.
  project: .tuist(
    compatibleXcodeVersions: .all,
    // Swift 6.4의 precise module tracking을 캐시/원격 빌드에서도 동일하게 사용한다.
    swiftVersion: .some("6.4.0"),
    plugins: [
      .local(path: .relativeToRoot("Plugins/ProjectTemplatePlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPackagePlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPlugin"))
    ],
    generationOptions: .options(
      optionalAuthentication: true,
      // Xcode Compilation Cache는 `tuist setup cache`, 바이너리 캐시는 `tuist cache warm`으로 준비한다.
      enableCaching: true
    ),
    installOptions: .options(),
    cacheOptions: .options(
      profiles: .profiles(default: .onlyExternal)
    )
  )
)
