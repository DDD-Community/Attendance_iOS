//
//  GoogleLoginManager.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/1/24.
//

import CryptoKit
import SwiftUI

import GoogleSignIn

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
