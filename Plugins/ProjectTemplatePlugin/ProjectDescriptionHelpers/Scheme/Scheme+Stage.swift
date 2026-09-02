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
        allModuleTestTargets(appName: name),
        configuration: .stage,
        options: .options(coverage: true)
      ),
      runAction: .runAction(configuration: .stage, executable: appTarget),
      archiveAction: .archiveAction(configuration: .stage),
      profileAction: .profileAction(configuration: .stage),
      analyzeAction: .analyzeAction(configuration: .stage)
    )
  }

  private static func allModuleTestTargets(appName: String) -> [TestableTarget] {
    let repositoryRootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
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
      return FileManager.default.fileExists(atPath: manifestURL.path) ? projectURL : nil
    } ?? []

    return projectDirectoryURLs
      .map { projectURL in
        let relativeProjectPath = projectURL.path.replacingOccurrences(
          of: repositoryRootURL.path + "/",
          with: ""
        )
        let moduleName = projectURL.lastPathComponent == "App"
          ? appName
          : projectURL.lastPathComponent

        return .testableTarget(
          target: .project(
            path: .relativeToRoot(relativeProjectPath),
            target: "\(moduleName)Tests"
          )
        )
      }
      .sorted { $0.target.targetName < $1.target.targetName }
  }
}
