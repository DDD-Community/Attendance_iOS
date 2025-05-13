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
    print("❌ 실행 실패: \(error)")
    return -1
  }
}

func generate() {
  setenv("TUIST_ROOT_DIR", FileManager.default.currentDirectoryPath, 1)
  run("tuist", arguments: ["generate"])
}

func fetch() {
  run("tuist", arguments: ["fetch"])
}

func build() {
  clean()
  fetch()
  generate()
}

func clean() {
  run("tuist", arguments: ["clean"])
}

func install() {
  run("tuist", arguments: ["install"])
}

func cache() {
  run("tuist", arguments: ["cache", "DDDAttendance"])
}

func scaffoldModule(template: String, layer: String, name: String, author: String) {
  run("tuist", arguments: [
    "scaffold",
    template,
    "--layer", layer,
    "--name", name,
    "--author", author
  ])
}

func reset() {
  print("🧹 캐시 및 로컬 빌드 정리 중...")
  run("rm", arguments: ["-rf", "\(NSHomeDirectory())/Library/Caches/Tuist"])
  run("rm", arguments: ["-rf", "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"])
  run("rm", arguments: ["-rf", ".tuist", ".build"])
  fetch()
  generate()
}

enum Command: String {
  case generate, fetch, build, clean, install, cache, module, reset
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
      ./tuisttool module <template> <layer> <name> <author>
    """)
  exit(1)
}

switch command {
case .generate: generate()
case .fetch:    fetch()
case .build:    build()
case .clean:    clean()
case .install:  install()
case .cache:    cache()
case .reset:    reset()
case .module:
  guard args.count >= 5 else {
    print("사용법: ./tuisttool module <template> <layer> <name> <author>")
    exit(1)
  }
  scaffoldModule(
    template: String(args[1]),
    layer: String(args[2]),
    name: String(args[3]),
    author: String(args[4])
  )
}
