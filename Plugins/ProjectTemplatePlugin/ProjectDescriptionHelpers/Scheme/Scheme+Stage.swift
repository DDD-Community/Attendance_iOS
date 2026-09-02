//
//  Scheme+Stage.swift
//  ProjectTemplatePlugin
//
//  Stage CI 스킴 구성.
//

import Foundation
import ProjectDescription

public extension Scheme {
  /// Stage 앱과 `Projects/**/Tests`를 하나의 CI 검증 스킴으로 구성한다.
  static func stageWorkspace(name: String) -> Scheme {
    let appTarget = TargetReference.project(
      path: "Projects/App",
      target: name
    )

    return .scheme(
      name: "\(name)-Stage",
      shared: true,
      buildAction: .buildAction(
        targets: [appTarget],
        postActions: [
          .executionAction(
            title: "Inspect Build",
            scriptText: "$HOME/.local/bin/mise x -C $SRCROOT -- tuist inspect build",
            target: appTarget
          )
        ],
        runPostActionsOnFailure: true
      ),
      testAction: .targets(
        allModuleTestTargets(),
        configuration: .stage,
        postActions: [
          .executionAction(
            title: "Inspect Test",
            scriptText: "$HOME/.local/bin/mise x -C $SRCROOT -- tuist inspect test",
            target: appTarget
          )
        ],
        options: .options(coverage: true)
      ),
      runAction: .runAction(configuration: .stage, executable: appTarget),
      archiveAction: .archiveAction(configuration: .stage),
      profileAction: .profileAction(configuration: .stage),
      analyzeAction: .analyzeAction(configuration: .stage)
    )
  }

  private static func allModuleTestTargets() -> [TestableTarget] {
    // 저장소 루트를 CWD 로 잡으면 안 된다. `tuist test --path <repo>` 처럼
    // 작업 디렉토리가 저장소 루트가 아닌 채로 매니페스트가 평가되면 Projects 를 못 찾고,
    // 아래 `?? []` 에 걸려 테스트 0개짜리 초록불이 나온다(실제 CI 에서 발생).
    // 이 파일 위치에서 루트를 역산한다: <root>/Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Scheme/
    let repositoryRootURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
    let projectsRootURL = repositoryRootURL.appendingPathComponent("Projects", isDirectory: true)
    let projectDirectoryURLs = FileManager.default.enumerator(
      at: projectsRootURL,
      includingPropertiesForKeys: [.isDirectoryKey],
      options: [.skipsHiddenFiles, .skipsPackageDescendants]
    )?.compactMap { element -> URL? in
      guard let url = element as? URL, url.lastPathComponent == "Tests" else {
        return nil
      }

      let projectURL = url.deletingLastPathComponent()
      let manifestURL = projectURL.appendingPathComponent("Project.swift")
      guard projectURL.lastPathComponent != "App" else {
        // 모든 모듈 테스트가 DDDAttendance를 공용 host로 사용한다. App 테스트까지
        // 같은 action에 중복 포함하면 App State 종료 뒤 testmanagerd 대기가 재발할 수 있다.
        return nil
      }
      return FileManager.default.fileExists(atPath: manifestURL.path) ? projectURL : nil
    } ?? []

    let testableTargets: [TestableTarget] = projectDirectoryURLs
      .map { projectURL in
        let relativeProjectPath = projectURL.path.replacingOccurrences(
          of: repositoryRootURL.path + "/",
          with: ""
        )
        let moduleName = projectURL.lastPathComponent

        return .testableTarget(
          target: .project(
            path: .relativeToRoot(relativeProjectPath),
            target: "\(moduleName)Tests"
          )
        )
      }
      .sorted { $0.target.targetName < $1.target.targetName }

    // 빈 목록을 그대로 돌려주면 실행할 테스트가 없는 채로 CI 가 통과한다.
    // 커버리지·테스트 유실을 초록불로 덮지 않도록 여기서 끊는다.
    guard !testableTargets.isEmpty else {
      fatalError("Stage 스킴에 포함할 모듈 테스트 타깃을 찾지 못했다: \(projectsRootURL.path)")
    }
    return testableTargets
  }
}
