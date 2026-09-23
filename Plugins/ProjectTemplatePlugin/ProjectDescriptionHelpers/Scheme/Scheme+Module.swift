//
//  Scheme+Module.swift
//  ProjectTemplatePlugin
//
//  Demo가 있는 모듈의 구현/테스트 스킴과 Demo 실행 스킴을 분리한다.
//

import ProjectDescription

public extension Scheme {
  static func module(name: String, hasTests: Bool) -> Scheme {
    makeModuleScheme(
      name: name,
      target: name,
      testTargets: hasTests ? ["\(name)Tests"] : []
    )
  }

  static func demo(name: String) -> Scheme {
    makeModuleScheme(name: name, target: name)
  }

  private static func makeModuleScheme(
    name: String,
    target: String,
    testTargets: [TestableTarget] = []
  ) -> Scheme {
    return .scheme(
      name: name,
      shared: true,
      buildAction: .buildAction(targets: [.target(target)]),
      testAction: testTargets.isEmpty
        ? nil
        : .targets(
          testTargets,
          configuration: .stage,
          options: .options(coverage: true)
        ),
      runAction: .runAction(configuration: .stage),
      archiveAction: .archiveAction(configuration: .stage),
      profileAction: .profileAction(configuration: .stage),
      analyzeAction: .analyzeAction(configuration: .stage)
    )
  }
}
