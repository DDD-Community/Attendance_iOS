//
//  Modules.swift
//  Plugins
//
//  레이어별 모듈 카탈로그(단일 출처).
//  모듈 추가 = case 한 줄. rawValue 가 실제 타깃명이라 오타로 깨지지 않는다.
//

import Foundation
import ProjectDescription

public enum FeatureModule: String, CaseIterable {
  case splash = "Splash"
  case auth = "Auth"
  case management = "Management"
  case profile = "Profile"
  case member = "Member"
  case onBoarding = "OnBoarding"
  case web = "Web"

  /// Projects/Feature/<name>
  var path: Path { .relativeToFeature(rawValue) }
}

public enum CoreModule: String, CaseIterable {
  case logger = "DDDCoreLogger"
  case network = "DDDNetwork"
  case coreUI = "DDDCoreUI"
  case coreUtility = "DDDCoreUtility"
  case thirdParty = "DDDThirdParty"

  /// Projects/Core/<name>
  var path: Path { .relativeToCore(rawValue) }
}

public enum NetworkModule: String, CaseIterable {
  case networks = "Networks"
  case foundations = "Foundations"
  case thirdPartys = "ThirdPartys"

  /// Projects/Network/<name>
  var path: Path { .relativeToNetwork(rawValue) }
}

public enum DataModule: String, CaseIterable {
  case model = "Model"
  case repository = "Repository"
  case service = "Service"
  case api = "API"

  /// Projects/Data/<name>
  var path: Path { .relativeToData(rawValue) }
}

public enum DomainModule: String, CaseIterable {
  case useCase = "UseCase"
  case domainInterface = "DomainInterface"
  case entity = "Entity"

  /// Projects/Domain/<name>
  var path: Path { .relativeToDomain(rawValue) }
}

public enum UIModule: String, CaseIterable {
  case designKit = "DDDDesignKit"
  case sharedUI = "DDDSharedUI"

  /// Projects/UI/<name>
  var path: Path { .relativeToUI(rawValue) }
}
