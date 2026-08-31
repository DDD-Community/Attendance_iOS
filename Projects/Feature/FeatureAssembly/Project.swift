import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "FeatureAssembly",
  bundleId: .appBundleID(name: ".FeatureAssembly"),
  product: Project.Environment.presentationProduct,
  settings:  .moduleSettings,
  dependencies: [
    .feature(.auth),
    .feature(.splash),
    .feature(.management),
    .feature(.member),
    .feature(.onBoarding),
    .feature(.profile),
    .feature(.web),

    // 조립 대상 구현 모듈 — 인터페이스에 liveValue 를 붙이기 위해 여기서만 구현을 본다.
    .data(.repository),
    .domain(.useCase),
    .domain(.domainInterface),
    .network(.foundations)
  ],
  sources: ["Sources/**"]
)
