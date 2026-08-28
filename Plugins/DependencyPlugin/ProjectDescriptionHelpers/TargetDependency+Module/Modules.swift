//
//  Modules.swift
//  Plugins
//
//  Created by 서원지 on 2/21/24.
//

import Foundation
import ProjectDescription

public enum ModulePath {
  case Presentation(Presentations)
  case Core(Cores)
  case Network(Networks)
  case Interface(Interfaces)
  case Domain(Domains)
  case Data(Datas)
  case UI(UIs)
}

// MARK: -  앱  모듈

public extension ModulePath {
  enum App: String, CaseIterable {
    case iOS
    case iPad

    public static let name: String = "App"
  }
}

// MARK: FeatureModule

public extension ModulePath {
  enum Presentations: String, CaseIterable {
    case Presentation
    case Splash
    case Auth
    case Management
    case Profile
    case Member
    case OnBoarding
    case Web

    public static let name: String = "Presentation"
  }
}

// MARK: -  CoreMoudule

public extension ModulePath {
  enum Cores: String, CaseIterable {
    case DDDCoreUI
    case DDDCoreUtility
    case DDDThirdParty

    public static let name: String = "Core"
  }
}

// MARK: -  CoreDomainModule

public extension ModulePath {
  enum Networks: String, CaseIterable {
    case Networks
    case Foundations
    case ThirdPartys

    public static let name: String = "Network"
  }
}

// MARK: -  CoreMoudule

public extension ModulePath {
  enum Datas: String, CaseIterable {
    case Model
    case Repository
    case Service
    case API

    public static let name: String = "Data"
  }
}

// MARK: -  CoreMoudule

public extension ModulePath {
  enum Domains: String, CaseIterable {
    case UseCase
    case DomainInterface
    case QRCode

    public static let name: String = "Domain"
    case Entity
  }
}

// MARK: -  CoreMoudule

public extension ModulePath {
  enum Interfaces: String, CaseIterable {
    case Interface

    public static let name: String = "Interface"
  }
}

public extension ModulePath {
  enum UIs: String, CaseIterable {
    case DDDDesignKit
    case DDDSharedUI

    public static let name: String = "UI"
  }
}
