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
  case feature
  case core
  case service
  case data
  case domain
  case ui
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

/// 레이어마다 scaffold 대상 디렉터리, 카탈로그 enum, 의존성 헬퍼, 엄브렐러가 다르다.
/// 이 대응표를 한곳에 두어야 모듈 추가가 손으로 세 파일을 고치는 일이 되지 않는다.
private enum ModuleLayer: String, CaseIterable {
  case feature = "Feature"
  case core = "Core"
  case service = "Service"
  case data = "Data"
  case domain = "Domain"
  case ui = "UI"

  /// Modules.swift 안의 카탈로그 enum 이름.
  var catalogEnumName: String {
    switch self {
    case .feature: return "FeatureModule"
    case .core: return "CoreModule"
    case .service: return "ServiceModule"
    case .data: return "DataModule"
    case .domain: return "DomainModule"
    case .ui: return "UIModule"
    }
  }

  /// `.feature(.splash)` 에서 `feature` 에 해당하는 TargetDependency 헬퍼 이름.
  var dependencyHelperName: String {
    switch self {
    case .feature: return "feature"
    case .core: return "core"
    case .service: return "service"
    case .data: return "data"
    case .domain: return "domain"
    case .ui: return "ui"
    }
  }

  /// 새 모듈을 자동으로 물릴 엄브렐러. UI 레이어는 엄브렐러가 없다.
  var umbrellaManifestPath: String? {
    switch self {
    case .feature: return "Projects/Feature/FeatureAssembly/Project.swift"
    case .core: return "Projects/Core/CoreAssembly/Project.swift"
    case .service: return "Projects/Service/ServiceAssembly/Project.swift"
    case .data: return "Projects/Data/DataAssembly/Project.swift"
    case .domain: return "Projects/Domain/DomainAssembly/Project.swift"
    case .ui: return nil
    }
  }

  init?(argument: String) {
    let normalized = argument.lowercased()
    guard let matched = ModuleLayer.allCases.first(where: { $0.rawValue.lowercased() == normalized })
    else {
      return nil
    }
    self = matched
  }
}

private let moduleCatalogPath =
  "Plugins/DependencyPlugin/ProjectDescriptionHelpers/TargetDependency+Module/Modules.swift"

/// Module 템플릿이 author 를 required 로 받지만 파일 헤더는 저장소 전체가 DDD 로 통일돼 있다.
/// 명령 인자로 열어두면 헤더만 어긋나므로 고정값으로 넘긴다.
private let scaffoldAuthor = "DDD"

/// `DDDNetwork` → `network`, `Splash` → `splash`.
/// 카탈로그에는 `logger = "DDDCoreLogger"` 처럼 줄여 쓴 case 도 있어서
/// 규칙으로 못 맞추는 이름은 `--case` 로 직접 지정한다.
private func defaultCaseName(for moduleName: String) -> String {
  var name = moduleName
  if name.hasPrefix("DDD"), name.count > 3 {
    name.removeFirst(3)
  }
  guard let first = name.first else { return name }
  return first.lowercased() + name.dropFirst()
}

/// `anchor` 가 들어간 첫 줄 바로 아래에 `line` 을 끼워 넣는다.
/// `guardText` 가 이미 파일에 있으면 재실행해도 중복으로 쌓이지 않는다.

/// Demo 앱을 뺀 모듈 그래프를 만든다.
///
/// Demo 는 피처마다 하나씩 있는데 다른 모듈이 Demo 를 의존하지 않는다.
/// 그래프에 넣으면 노드만 늘고 계층 구조가 안 보인다.
///
/// tuist graph 에는 특정 타깃을 빼는 옵션이 없다(--skip-test-targets 등만 있다).
/// 그래서 dot 으로 뽑아 Demo 노드를 걸러낸 뒤 graphviz 로 직접 렌더링한다.
private func renderGraphWithoutDemo(
  extraTuistArguments: [String],
  forwardedArguments: [String]
) -> Int32 {
  let fileManager = FileManager.default
  let workDirectory = fileManager.temporaryDirectory
    .appendingPathComponent("attendance-graph-\(UUID().uuidString)")

  do {
    try fileManager.createDirectory(at: workDirectory, withIntermediateDirectories: true)
  } catch {
    FileHandle.standardError.write(Data("작업 디렉터리를 만들지 못했습니다: \(error)\n".utf8))
    return 1
  }
  defer { try? fileManager.removeItem(at: workDirectory) }

  let dotStatus = runTuist(arguments: [
    "graph",
    "--no-open",
    "--skip-external-dependencies",
    "--format", "dot",
    "--output-path", workDirectory.path
  ] + extraTuistArguments + forwardedArguments)
  guard dotStatus == 0 else { return dotStatus }

  let dotURL = workDirectory.appendingPathComponent("graph.dot")
  guard let rawGraph = try? String(contentsOf: dotURL, encoding: .utf8) else {
    FileHandle.standardError.write(Data("dot 파일을 읽지 못했습니다: \(dotURL.path)\n".utf8))
    return 1
  }

  // 노드 선언(`AuthDemo [..]`)과 엣지(`AuthDemo -> Auth`) 양쪽에서
  // 이름이 Demo 로 끝나는 줄을 지운다. dot 출력은 식별자에 따옴표를 붙이지 않는다.
  let filtered = rawGraph
    .split(separator: "\n", omittingEmptySubsequences: false)
    .filter { line in
      line.range(of: #"\b[A-Za-z0-9_]+Demo\b"#, options: .regularExpression) == nil
    }
    .joined(separator: "\n")

  let filteredURL = workDirectory.appendingPathComponent("graph-without-demo.dot")
  do {
    try filtered.write(to: filteredURL, atomically: true, encoding: .utf8)
  } catch {
    FileHandle.standardError.write(Data("필터링한 dot 을 쓰지 못했습니다: \(error)\n".utf8))
    return 1
  }

  let renderStatus = run("dot", arguments: ["-Tpng", filteredURL.path, "-o", "graph.png"])
  guard renderStatus == 0 else {
    FileHandle.standardError.write(Data("graphviz 렌더링에 실패했습니다. `brew install graphviz` 가 필요합니다.\n".utf8))
    return renderStatus
  }

  print("graph.png 를 만들었습니다 (Demo 제외)")
  return 0
}

@discardableResult
private func insertLine(
  _ line: String,
  afterLineContaining anchor: String,
  skipIfContains guardText: String,
  inFileAt path: String
) -> Bool {
  guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
    FileHandle.standardError.write(Data("파일을 읽지 못했습니다: \(path)\n".utf8))
    return false
  }

  if contents.contains(guardText) {
    print("이미 등록되어 있어 건너뜁니다: \(guardText)")
    return true
  }

  var lines = contents.components(separatedBy: "\n")
  guard let anchorIndex = lines.firstIndex(where: { $0.contains(anchor) }) else {
    FileHandle.standardError.write(Data("기준 위치를 찾지 못했습니다: \(anchor) (\(path))\n".utf8))
    return false
  }

  lines.insert(line, at: lines.index(after: anchorIndex))

  do {
    try lines.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
  } catch {
    FileHandle.standardError.write(Data("파일을 쓰지 못했습니다: \(path) - \(error)\n".utf8))
    return false
  }

  print("등록: \(line.trimmingCharacters(in: .whitespaces)) → \(path)")
  return true
}

private func scaffoldModule(layer presetLayer: ModuleLayer?, arguments: [String]) -> Int32 {
  var positional: [String] = []
  var caseNameOverride: String?
  var index = arguments.startIndex
  while index < arguments.endIndex {
    if arguments[index] == "--case", arguments.index(after: index) < arguments.endIndex {
      caseNameOverride = arguments[arguments.index(after: index)]
      index = arguments.index(index, offsetBy: 2)
    } else {
      positional.append(arguments[index])
      index = arguments.index(after: index)
    }
  }

  let layer: ModuleLayer
  if let presetLayer {
    layer = presetLayer
  } else {
    let rawLayer = positional.first ?? prompt("레이어를 입력하세요 (Feature/Core/Service/Data/Domain/UI)")
    guard let parsed = ModuleLayer(argument: rawLayer) else {
      FileHandle.standardError.write(Data("알 수 없는 레이어: \(rawLayer)\n".utf8))
      return 64
    }
    layer = parsed
    positional = Array(positional.dropFirst())
  }

  let name = positional.first ?? prompt("\(layer.rawValue) 모듈 이름을 입력하세요")
  guard !name.isEmpty else {
    FileHandle.standardError.write(Data("모듈 이름이 필요합니다.\n".utf8))
    return 64
  }

  let caseName = caseNameOverride ?? defaultCaseName(for: name)

  let scaffoldStatus = runTuist(arguments: [
    "scaffold", "Module",
    "--layer", layer.rawValue,
    "--name", name,
    "--author", scaffoldAuthor
  ])
  guard scaffoldStatus == 0 else { return scaffoldStatus }

  // 카탈로그에 case 가 있어야 `.feature(.x)` 같은 의존성 표기가 컴파일된다.
  guard insertLine(
    "  case \(caseName) = \"\(name)\"",
    afterLineContaining: "public enum \(layer.catalogEnumName): String, CaseIterable {",
    skipIfContains: "= \"\(name)\"",
    inFileAt: moduleCatalogPath
  ) else {
    return 1
  }

  if let umbrellaManifestPath = layer.umbrellaManifestPath {
    guard insertLine(
      "    .\(layer.dependencyHelperName)(.\(caseName)),",
      afterLineContaining: "dependencies: [",
      skipIfContains: ".\(layer.dependencyHelperName)(.\(caseName))",
      inFileAt: umbrellaManifestPath
    ) else {
      return 1
    }
  } else {
    print("\(layer.rawValue) 레이어는 엄브렐러가 없어 의존성 등록을 건너뜁니다.")
  }

  return runTuist(arguments: ["generate"])
}

private func printHelp() {
  print(
    """
    🚀 DDDAttendance Tuist 도구

    기본 명령어:
      ./make setup          # mise 도구 설치 + 의존성 설치 + 프로젝트 생성
      ./make generate       # 프로젝트 생성 (Demo 앱 제외)
      DEMO=1 ./make generate  # Demo 앱까지 포함해 생성
      ./make build          # 클린 + 의존성 설치 + 프로젝트 생성
      ./make install        # 의존성 설치 + 프로젝트 생성
      ./make cache          # 바이너리 캐시 생성
      ./make test           # 전체 테스트 실행
      ./make format         # SwiftFormat 적용
      ./make lint           # SwiftFormat 검사
      ./make clean          # 프로젝트 정리
      ./make reset          # 앱 DerivedData 정리 + clean + install + generate

    모듈 생성 (scaffold + 카탈로그 case + 엄브렐러 의존성 자동 등록):
      ./make feature <이름> [--case <케이스명>]
      ./make core <이름> [--case <케이스명>]
      ./make service <이름> [--case <케이스명>]
      ./make data <이름> [--case <케이스명>]
      ./make domain <이름> [--case <케이스명>]
      ./make ui <이름> [--case <케이스명>]
      ./make module <레이어> <이름> # 레이어를 인자로 받는 형태
      ./make moduleinit     # module 명령의 호환 별칭

    케이스명은 모듈명에서 DDD 접두를 떼고 첫 글자를 소문자로 바꿔 만든다
    (DDDNetwork → network). 규칙과 다르면 --case 로 직접 지정한다.

    의존성 그래프:
      ./make graph          # 외부 패키지·Demo 를 제외한 모듈 그래프 생성
      ./make graph:prod     # 외부 패키지·Demo·테스트 타깃을 제외한 그래프 생성
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
    return scaffoldModule(layer: nil, arguments: forwardedArguments)

  case .feature:
    return scaffoldModule(layer: .feature, arguments: forwardedArguments)

  case .core:
    return scaffoldModule(layer: .core, arguments: forwardedArguments)

  case .service:
    return scaffoldModule(layer: .service, arguments: forwardedArguments)

  case .data:
    return scaffoldModule(layer: .data, arguments: forwardedArguments)

  case .domain:
    return scaffoldModule(layer: .domain, arguments: forwardedArguments)

  case .ui:
    return scaffoldModule(layer: .ui, arguments: forwardedArguments)

  case .graph:
    return renderGraphWithoutDemo(
      extraTuistArguments: [],
      forwardedArguments: forwardedArguments
    )

  case .productionGraph:
    return renderGraphWithoutDemo(
      extraTuistArguments: ["--skip-test-targets"],
      forwardedArguments: forwardedArguments
    )

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
