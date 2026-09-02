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
    // 조립 루트로서 계층별 Assembly 를 모두 링크한다. UseCase 의 liveValue 가
    // 여기서 앱 링크 그래프에 들어간다(App 은 FeatureAssembly 하나만 안다).
    .domainAssembly,
    .dataAssembly
  ],
  sources: ["Sources/**"]
)
