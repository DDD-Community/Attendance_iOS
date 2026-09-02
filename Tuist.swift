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
    swiftVersion: .some("6.0.0"),
    plugins: [
      .local(path: .relativeToRoot("Plugins/ProjectTemplatePlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPackagePlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPlugin"))
    ],
    generationOptions: .options(
      optionalAuthentication: true,
      // 로컬과 CI 모두 `tuist setup cache`로 실행한 Xcode Compilation Cache를 사용한다.
      enableCaching: true
    ),
    installOptions: .options(),
    // Module cache 는 외부 패키지까지만 적용한다.
    // all-possible 로 내부 모듈까지 바이너리로 바꾸면
    // (1) PR 커버리지가 집계할 소스가 사라지고
    // (2) `tuist inspect implicit-imports` 가 잡아낸 암묵적 import 들이
    //     DerivedData 안전망을 잃고 컴파일 에러로 드러난다.
    cacheOptions: .options(
      profiles: .profiles(default: .onlyExternal)
    )
  )
)
