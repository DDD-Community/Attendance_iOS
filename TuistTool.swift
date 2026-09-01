//
//  TuistTool.swift
//  DDDAttendance
//
//  Created by DDD on 9/1/26.
//

import Foundation

private enum Command: String {
  case generate
  case build
  case install
  case cache
  case test
  case clean
  case reset
  case moduleInit = "moduleinit"
  case graph
  case productionGraph = "graph:prod"
  case help
}

@discardableResult
private func run(_ executable: String, arguments: [String]) -> Int32 {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = [executable] + arguments
  process.standardInput = FileHandle.standardInput
  process.standardOutput = FileHandle.standardOutput
  process.standardError = FileHandle.standardError

  do {
    try process.run()
    process.waitUntilExit()
    return process.terminationStatus
  } catch {
    FileHandle.standardError.write(Data("실행 실패: \(error)\n".utf8))
    return 1
  }
}

@discardableResult
private func runTuist(arguments: [String]) -> Int32 {
  return run("mise", arguments: ["exec", "--", "tuist"] + arguments)
}

private func printHelp() {
  print(
    """
    🚀 DDDAttendance Tuist 도구

    기본 명령어:
      ./make generate       # 프로젝트 생성
      ./make build          # 클린 + 의존성 설치 + 프로젝트 생성
      ./make install        # 의존성 설치
      ./make cache          # 바이너리 캐시 생성
      ./make test           # 전체 테스트 실행
      ./make clean          # 프로젝트 정리
      ./make reset          # 전체 캐시 초기화
      ./make moduleinit     # 새 모듈 생성

    의존성 그래프:
      ./make graph          # 외부 패키지를 제외한 모듈 그래프 생성
      ./make graph:prod     # 외부 패키지와 테스트 타깃을 제외한 그래프 생성
    """
  )
}

private func execute(_ command: Command, forwardedArguments: [String]) -> Int32 {
  switch command {
  case .generate:
    return runTuist(arguments: ["generate"] + forwardedArguments)

  case .build:
    for arguments in [["clean"], ["install"], ["generate"]] {
      let status = runTuist(arguments: arguments)
      guard status == 0 else { return status }
    }
    return 0

  case .install:
    let status = runTuist(arguments: ["install"] + forwardedArguments)
    guard status == 0 else { return status }
    return runTuist(arguments: ["generate"])

  case .cache:
    return runTuist(arguments: ["cache"] + forwardedArguments)

  case .test:
    return runTuist(arguments: ["test"] + forwardedArguments)

  case .clean:
    return runTuist(arguments: ["clean"] + forwardedArguments)

  case .reset, .moduleInit:
    return run("./tuisttool", arguments: [command.rawValue] + forwardedArguments)

  case .graph:
    return runTuist(arguments: [
      "graph",
      "--no-open",
      "--skip-external-dependencies",
      "--format", "png",
      "--output-path", "."
    ])

  case .productionGraph:
    return runTuist(arguments: [
      "graph",
      "--no-open",
      "--skip-external-dependencies",
      "--skip-test-targets",
      "--format", "png",
      "--output-path", "."
    ])

  case .help:
    printHelp()
    return 0
  }
}

let arguments = Array(CommandLine.arguments.dropFirst())
let rawCommand = arguments.first ?? Command.help.rawValue
let normalizedCommand = ["-h", "--help"].contains(rawCommand) ? Command.help.rawValue : rawCommand
let forwardedArguments = Array(arguments.dropFirst())

guard let command = Command(rawValue: normalizedCommand) else {
  FileHandle.standardError.write(Data("알 수 없는 명령어: \(rawCommand)\n\n".utf8))
  printHelp()
  exit(64)
}

exit(execute(command, forwardedArguments: forwardedArguments))
