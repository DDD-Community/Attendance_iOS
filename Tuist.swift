//
//  Tuist.swift
//  Manifests
//
//  Created by DDD on 2/4/25.
//

import ProjectDescription
import Foundation

let tuist = Tuist(
  fullHandle:  "DDD2026/attendance",
  // 캐시 업로드는 CI 에서만 한다. 로컬은 읽기 전용으로 두어 개발 중 업로드 비용을 없앤다.
  cache: .cache(upload: Environment.isCI),
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
      // CI 와 로컬에서 `tuist setup cache`로 실행한 캐시 서비스를 사용한다.
      enableCaching: true
      // TODO: Moya/RxMoya 를 걷어내고 남은 정적 중복 링크 경고를 없앤 뒤
      // warningsAsErrors: .only([.staticSideEffects]) 를 켠다.
      // 지금 켜면 기존 경고 6건 때문에 generate 가 바로 실패한다.
    ),
    // 외부 패키지 manifest 의 Swift 6.2 deprecation 경고가 CI 로그를 덮지 않게 한다.
    // 실제 registry URL 을 운영하지 않으므로 SCM → registry 강제 변환은 사용하지 않는다.
    installOptions: .options(
      passthroughSwiftPackageManagerArguments: ["--quiet"]
    )
  )
)
