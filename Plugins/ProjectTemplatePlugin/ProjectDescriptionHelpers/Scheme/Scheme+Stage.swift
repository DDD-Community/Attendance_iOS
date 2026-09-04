//
//  Scheme+Stage.swift
//  ProjectTemplatePlugin
//
//  Stage CI 스킴 구성.
//

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
      testAction: .testPlans(
        [.relativeToRoot("Projects/App/Tests/DDDAttendance.xctestplan")],
        configuration: .stage,
        postActions: [
          .executionAction(
            title: "Inspect Test",
            scriptText: "$HOME/.local/bin/mise x -C $SRCROOT -- tuist inspect test",
            target: appTarget
          )
        ]
      ),
      runAction: .runAction(configuration: .stage, executable: appTarget),
      archiveAction: .archiveAction(configuration: .stage),
      profileAction: .profileAction(configuration: .stage),
      analyzeAction: .analyzeAction(configuration: .stage)
    )
  }

}
