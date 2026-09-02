import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDDesignKit",
  bundleId: .appBundleID(name: ".DDDDesignKit"),
  // 리소스 번들을 갖는 UI 모듈은 동적 프레임워크로 둔다.
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.animation),
    .core(.coreUI),
    .core(.thirdParty),
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  hasTests: true,
  hasDemo: true
)
