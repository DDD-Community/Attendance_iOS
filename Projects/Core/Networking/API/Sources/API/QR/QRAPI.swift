//
//  QRAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public enum QRAPI: String {
  case qrcodeValidate
  
  public var qrcodeDescription: String {
    switch self {
    case .qrcodeValidate:
      return "attend-with-qr/"
    }
  }
}
