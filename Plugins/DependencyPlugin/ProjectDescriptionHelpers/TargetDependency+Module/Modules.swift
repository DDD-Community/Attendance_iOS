//
//  Modules.swift
//  Plugins
//
//  Created by 서원지 on 2/21/24.
//

import Foundation
import ProjectDescription

public enum ModulePath {
  case Presentatios(Presentations)
  case Core(Cores)
  case Network(Networks)
  case Interface(Interfaces)
  case Domain(Domains)
  case Data(Datas)
  case Shared(Shareds)
}

//MARK: -  앱  모듈
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
    public static let name: String = "Presentation"
  }
}

//MARK: -  CoreMoudule
public extension ModulePath {
  enum Cores: String, CaseIterable {
    case Core
    
    public static let name: String = "Core"
  }
}

//MARK: -  CoreDomainModule
public extension ModulePath {
  enum Networks: String, CaseIterable {
    case API
    case Networks
    case Foundations
    case Model
    case Service
    case DiContainer
    case UseCase
    case ThirdPartys
    
    
    public static let name: String = "Network"
  }
}

//MARK: -  CoreMoudule
public extension ModulePath {
  enum Datas: String, CaseIterable {
    case Model
    case Repository

    public static let name: String = "Data"
  }
}


//MARK: -  CoreMoudule
public extension ModulePath {
  enum Domains: String, CaseIterable {
    case UseCase
    case DomainInterface


    public static let name: String = "Domain"
  }
}

//MARK: -  CoreMoudule
public extension ModulePath {
  enum Interfaces: String, CaseIterable {
    case Interface


    public static let name: String = "Interface"
  }
}


public extension ModulePath {
  enum Shareds: String, CaseIterable {
    case Shareds
    case DesignSystem
    case Utill
    case ThirdParty
    
    public static let name: String = "Shared"
  }
}


