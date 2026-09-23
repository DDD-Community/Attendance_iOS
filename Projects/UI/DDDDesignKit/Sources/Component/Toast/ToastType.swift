//
//  ToastType.swift
//  DDDDesignKit
//
//  Created by DDD on 12/29/25.
//

import SwiftUI

public enum ToastType: Equatable {
  case success(String)
  case error(String)
  case warning(String)
  case info(String)
  case loading(String)

  public var message: String {
    switch self {
      case .success(let message),
          .error(let message),
          .warning(let message),
          .info(let message),
          .loading(let message):
        return message
    }
  }

  public var backgroundColor: Color {
    switch self {
      case .success:
        return .gray40
      case .error:
        return .gray40
      case .warning:
        return .gray40
      case .info:
        return .gray40
      case .loading:
        return .gray60
    }
  }

  public var iconName: String? {
    switch self {
      case .success:
        return "checkBlue"
      case .error:
        return "errorXmark"
      case .warning:
        return "errorXmark"
      case .info:
        return "info.circle.fill"
      case .loading:
        return nil
    }
  }

  public var iconColor: Color {
    switch self {
      case .success:
        return .white
      case .error:
        return .red
      case .warning:
        return .red
      case .info:
        return .white
      case .loading:
        return .white
    }
  }
}
