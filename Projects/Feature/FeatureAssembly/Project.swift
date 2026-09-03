import DependencyPlugin
import DependencyPackagePlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "FeatureAssembly",
  bundleId: .appBundleID(name: ".FeatureAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    // App은 이 모듈의 bootstrap 하나만 호출하고, Data/Domain 조립은 아래로 전파된다.
    .dataAssembly,
    .domainAssembly,
    .feature(.auth),
    .feature(.management),
    .feature(.member),
    .feature(.onBoarding),
    .feature(.profile),
    .feature(.web),
    .feature(.sharedUI),
    .domain(.domainInterface),
    .domain(.entity),
    .domain(.useCase),
    .service(.auth, .interface),
    .core(.logger),
    .ui(.animation),
    .SPM.dependencies
  ],
  sources: ["Sources/**"]
)
