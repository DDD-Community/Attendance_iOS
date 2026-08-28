//
//  GoogleLoginManager.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import CryptoKit
import SwiftUI

struct GoogleLoginManager {
  static let shared = GoogleLoginManager()

  func getRootViewController()->UIViewController{
    guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
      return .init()
    }
    guard let root = screen.windows.first?.rootViewController else{
      return .init()
    }
    return root
  }
}
