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
    .feature(.auth),
    .feature(.splash),
    .feature(.management),
    .feature(.member),
    .feature(.onBoarding),
    .feature(.profile),
    .feature(.web),
    .feature(.sharedUI),

    // 구현 등록은 DataAssembly 가 끝내 놓았다. 여기서는 그걸 앱까지 실어 나르기만 한다.
    .dataAssembly
  ],
  sources: ["Sources/**"]
)
