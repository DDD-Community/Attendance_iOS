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
        // Tuist는 컨테이너 경로를 저장소 루트에서, Xcode는 실제 플랜 위치에서 해석한다.
        // 실제 파일은 App/Tests에 유지하고 이 루트 호환 링크로 두 해석 기준을 연결한다.
        [.relativeToRoot("DDDAttendance.xctestplan")],
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
