import Foundation

@discardableResult
func run(_ command: String, arguments: [String] = []) -> Int32 {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = [command] + arguments
  process.standardOutput = FileHandle.standardOutput
  process.standardError = FileHandle.standardError
  do {
    try process.run()
    process.waitUntilExit()
    return process.terminationStatus
  } catch {
    print("\u{274C} 실행 실패: \(error)")
    return -1
  }
}

func runCapture(_ command: String, arguments: [String] = []) throws -> String {
  let process = Process()
  let pipe = Pipe()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = [command] + arguments
  process.standardOutput = pipe
  try process.run()
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
}

func prompt(_ message: String) -> String {
  print("\(message): ", terminator: "")
  return readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}

func generate() { setenv("TUIST_ROOT_DIR", FileManager.default.currentDirectoryPath, 1); run("tuist", arguments: ["generate"]) }
func fetch()    { run("tuist", arguments: ["fetch"]) }
func build()    { clean(); fetch(); generate() }
func edit()     { run("tuist", arguments: ["edit"]) }
func clean()    { run("tuist", arguments: ["clean"]) }
func install()  { run("tuist", arguments: ["install"]) }
func cache()    { run("tuist", arguments: ["cache", "DDDAttendance"]) }

func reset() {
  print("\u{1F9F9} 캐시 및 로컬 빌드 정리 중...")
  run("rm", arguments: ["-rf", "\(NSHomeDirectory())/Library/Caches/Tuist"])
  run("rm", arguments: ["-rf", "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"])
  run("rm", arguments: ["-rf", ".tuist", ".build"])
  fetch(); generate()
}

func parseModulesFromFile(keyword: String) -> [String] {
  let filePath = "Plugins/DependencyPlugin/ProjectDescriptionHelpers/TargetDependency+Module/Modules.swift"
  guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("\u{2757}\u{FE0F} Modules.swift 파일을 읽을 수 없습니다.")
    return []
  }

  let pattern = "case (\\w+)"
  let regex = try? NSRegularExpression(pattern: pattern, options: [])
  let lines = content.components(separatedBy: .newlines)

  var result: [String] = []
  var inSection = false

  for line in lines {
    if line.contains("enum \(keyword)") { inSection = true; continue }
    if line.contains("public static let name:") { inSection = false }

    guard inSection else { continue }

    if let match = regex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
       let range = Range(match.range(at: 1), in: line) {
      result.append(String(line[range]))
    }
  }

  return result
}

func parseSPMLibraries() -> [String] {
  let filePath = "Plugins/DependencyPackagePlugin/ProjectDescriptionHelpers/DependencyPackage/Extension+TargetDependencySPM.swift"
  guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("\u{2757}\u{FE0F} SPM 목록 파일을 읽을 수 없습니다.")
    return []
  }

  let pattern = "static let (\\w+) ="
  let regex = try? NSRegularExpression(pattern: pattern, options: [])
  let lines = content.components(separatedBy: .newlines)

  var result: [String] = []

  for line in lines {
    if let match = regex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
       let range = Range(match.range(at: 1), in: line) {
      result.append(String(line[range]))
    }
  }

  return result
}

func registerModule() {
  print("\n🚀 새 모듈 등록을 시작합니다.")
  let moduleInput = prompt("모듈 이름을 입력하세요 (예: Presentation_Home, Shared_Logger 등)")
  let moduleName = prompt("생성할 모듈 이름을 입력하세요 (예: Home)")

  var dependencies: [String] = []
  while true {
    print("의존성 종류 선택: 1) SPM, 2) 내부 모듈, 3) 종료")
    let choice = prompt("번호 선택")
    if choice == "3" { break }

    if choice == "1" {
      let options = parseSPMLibraries()
      if options.isEmpty {
        print("\u{2757}\u{FE0F} SPM 의존성이 없습니다.")
        continue
      }
      for (i, opt) in options.enumerated() {
        print("  \(i + 1). \(opt)")
      }
      let selected = Int(prompt("선택할 번호 입력")) ?? 0
      if selected > 0 && selected <= options.count {
        dependencies.append(".SPM.\(options[selected - 1])")
      }
    } else if choice == "2" {
      let keyword = prompt("모듈 키워드 입력 (예: Networking, Shared 등)")
      let options = parseModulesFromFile(keyword: keyword)
      if options.isEmpty {
        print("\u{2757}\u{FE0F} Modules.swift에 '\(keyword)'에 해당하는 항목이 없습니다.")
        continue
      }
      for (i, opt) in options.enumerated() {
        print("  \(i + 1). \(opt)")
      }
      let selected = Int(prompt("선택할 번호 입력")) ?? 0
      if selected > 0 && selected <= options.count {
        dependencies.append(".\(keyword)(implements: .\(options[selected - 1]))")
      }
    } else {
      print("❌ 잘못된 선택입니다.")
    }
  }

  let author = (try? runCapture("git", arguments: ["config", "--get", "user.name"])) ?? "Unknown"
  let currentDate: String = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }()

  let layer: String = {
    let lower = moduleInput.lowercased()
    if lower.starts(with: "presentation") { return "Presentation" }
    else if lower.starts(with: "shared") { return "Shared" }
    else if lower.starts(with: "domain") { return "Core/Domain" }
    else if lower.starts(with: "data") { return "Core/Data" }
    else if lower.starts(with: "networking") { return "Core/Networking" }
    else { return "Core" }
  }()

  let result = run("tuist", arguments: [
    "scaffold", "Module",
    "--layer", layer,
    "--name", moduleName,
    "--author", author,
    "--current-date", currentDate
  ])

  if result == 0 {
    print("✅ 모듈 '\(moduleName)' scaffold 완료됨")

    let projectFile = "Projects/\(layer)/\(moduleName)/Project.swift"
    if let content = try? String(contentsOfFile: projectFile, encoding: .utf8) {
      if let range = content.range(of: "dependencies: [") {
        let insertIndex = content.index(after: range.upperBound)
        let indent = "    "
        let dependencyList = dependencies
          .map { "\(indent)\($0)" }
          .joined(separator: ",\n")

        let newContent: String
        if !dependencies.isEmpty {
          newContent = content[..<insertIndex] +
            "\n" + dependencyList + "," +
            content[insertIndex...]
          print("🔧 의존성 추가 완료:\n\(dependencyList)")
        } else {
          newContent = content
          print("\u{2139}\u{FE0F} 의존성이 없어 그대로 유지됩니다.")
        }

        try? String(newContent).write(toFile: projectFile, atomically: true, encoding: .utf8)
      }
    }
  } else {
    print("❌ 모듈 생성 실패")
  }
}

enum Command: String {
  case edit, generate, fetch, build, clean, install, cache, module, reset, moduleinit
}

let args = CommandLine.arguments.dropFirst()
guard let cmd = args.first, let command = Command(rawValue: cmd) else {
  print("""
    사용법:
      ./tuisttool generate
      ./tuisttool build
      ./tuisttool cache
      ./tuisttool clean
      ./tuisttool reset
      ./tuisttool moduleinit
    """)
  exit(1)
}

switch command {
case .edit:      edit()
case .generate:  generate()
case .fetch:     fetch()
case .build:     build()
case .clean:     clean()
case .install:   install()
case .cache:     cache()
case .reset:     reset()
case .moduleinit: registerModule()
case .module:
  print("사용법: 모듈 생성은 moduleinit 명령을 사용하세요")
}
