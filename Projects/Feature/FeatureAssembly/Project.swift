import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "FeatureAssembly",
  bundleId: .appBundleID(name: ".FeatureAssembly"),
  product: .staticFramework,
  settings:  .moduleSettings,
  dependencies: [
    // App의 live DependencyKey 구현을 링크한다. DataAssembly가 ServiceAssembly를
    // 의존하므로 둘 다 App 빌드 그래프와 -force_load 입력에 포함된다.
    .dataAssembly,
    .feature(.auth),
    .feature(.splash),
    .feature(.management),
    .feature(.member),
    .feature(.onBoarding),
    .feature(.profile),
    .feature(.web),
    .feature(.sharedUI),
  ],
  sources: ["Sources/**"]
)
