//
//  TuistTool.swift
//  DDDAttendance
//
//  Created by DDD on 9/1/26.
//

import Foundation

private enum Command: String {
  case setup
  case generate
  case build
  case install
  case cache
  case test
  case format
  case lint
  case clean
  case reset
  case module
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

private func prompt(_ message: String) -> String {
  print("\(message): ", terminator: "")
  return readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}

@discardableResult
private func runTuist(arguments: [String]) -> Int32 {
  return run("mise", arguments: ["exec", "--", "tuist"] + arguments)
}

private func installAndGenerate(forwardedArguments: [String] = []) -> Int32 {
  let installStatus = runTuist(arguments: ["install"] + forwardedArguments)
  guard installStatus == 0 else { return installStatus }
  return runTuist(arguments: ["generate"])
}

private func resetProject() -> Int32 {
  let fileManager = FileManager.default
  let derivedDataURL = fileManager.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Developer/Xcode/DerivedData", isDirectory: true)

  do {
    let entries = try fileManager.contentsOfDirectory(
      at: derivedDataURL,
      includingPropertiesForKeys: nil
    )
    for entry in entries where entry.lastPathComponent.hasPrefix("DDDAttendance-") {
      try fileManager.removeItem(at: entry)
      print("DerivedData 삭제: \(entry.lastPathComponent)")
    }
  } catch CocoaError.fileReadNoSuchFile {
    // DerivedData가 아직 없다면 정리할 것도 없으므로 다음 단계로 진행합니다.
  } catch {
    FileHandle.standardError.write(Data("DerivedData 정리 실패: \(error)\n".utf8))
    return 1
  }

  let cleanStatus = runTuist(arguments: ["clean"])
  guard cleanStatus == 0 else { return cleanStatus }
  return installAndGenerate()
}

private func scaffoldModule(arguments: [String]) -> Int32 {
  let layer = arguments.first ?? prompt("레이어를 입력하세요 (Feature/Core/Service/Data/Domain/UI)")
  let name = arguments.dropFirst().first ?? prompt("모듈 이름을 입력하세요")
  let author = arguments.dropFirst(2).first ?? "DDD"

  guard !layer.isEmpty, !name.isEmpty else {
    FileHandle.standardError.write(
      Data("사용법: ./make module <레이어> <모듈명> [작성자]\n".utf8)
    )
    return 64
  }

  let scaffoldStatus = runTuist(arguments: [
    "scaffold", "Module",
    "--layer", layer,
    "--name", name,
    "--author", author
  ])
  guard scaffoldStatus == 0 else { return scaffoldStatus }
  return runTuist(arguments: ["generate"])
}

private func printHelp() {
  print(
    """
    🚀 DDDAttendance Tuist 도구

    기본 명령어:
      ./make setup          # mise 도구 설치 + 의존성 설치 + 프로젝트 생성
      ./make generate       # 프로젝트 생성
      ./make build          # 클린 + 의존성 설치 + 프로젝트 생성
      ./make install        # 의존성 설치 + 프로젝트 생성
      ./make cache          # 바이너리 캐시 생성
      ./make test           # 전체 테스트 실행
      ./make format         # SwiftFormat 적용
      ./make lint           # SwiftFormat 검사
      ./make clean          # 프로젝트 정리
      ./make reset          # 앱 DerivedData 정리 + clean + install + generate
      ./make module <레이어> <이름> [작성자] # 새 모듈 생성
      ./make moduleinit     # module 명령의 호환 별칭

    의존성 그래프:
      ./make graph          # 외부 패키지를 제외한 모듈 그래프 생성
      ./make graph:prod     # 외부 패키지와 테스트 타깃을 제외한 그래프 생성
    """
  )
}

private func execute(_ command: Command, forwardedArguments: [String]) -> Int32 {
  switch command {
  case .setup:
    let setupStatus = run("mise", arguments: ["install"])
    guard setupStatus == 0 else { return setupStatus }
    return installAndGenerate(forwardedArguments: forwardedArguments)

  case .generate:
    return runTuist(arguments: ["generate"] + forwardedArguments)

  case .build:
    for arguments in [["clean"], ["install"], ["generate"]] {
      let status = runTuist(arguments: arguments)
      guard status == 0 else { return status }
    }
    return 0

  case .install:
    return installAndGenerate(forwardedArguments: forwardedArguments)

  case .cache:
    return runTuist(arguments: ["cache"] + forwardedArguments)

  case .test:
    return runTuist(arguments: ["test"] + forwardedArguments)

  case .format:
    return run("mise", arguments: ["exec", "--", "swiftformat", "."] + forwardedArguments)

  case .lint:
    return run("mise", arguments: ["exec", "--", "swiftformat", "--lint", "."] + forwardedArguments)

  case .clean:
    return runTuist(arguments: ["clean"] + forwardedArguments)

  case .reset:
    return resetProject()

  case .module, .moduleInit:
    return scaffoldModule(arguments: forwardedArguments)

  case .graph:
    return runTuist(arguments: [
      "graph",
      "--no-open",
      "--skip-external-dependencies",
      "--format", "png",
      "--output-path", "."
    ] + forwardedArguments)

  case .productionGraph:
    return runTuist(arguments: [
      "graph",
      "--no-open",
      "--skip-external-dependencies",
      "--skip-test-targets",
      "--format", "png",
      "--output-path", "."
    ] + forwardedArguments)

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
