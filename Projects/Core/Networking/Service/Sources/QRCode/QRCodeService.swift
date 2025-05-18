//
//  QRCodeService.swift
//  Service
//
//  Created by eunpyo on 5/18/25.
//

import Foundation

import Foundations

import AsyncMoya

public enum QRCodeService {
  case createQRCode
}

extension QRCodeService: BaseTargetType {
  public var domain: AttendanceDomain {
    return .qr
  }

  public var urlPath: String {
    switch self {
    case .createQRCode:
      return ""
    }
  }

  public var error: [Int : NetworkError]? {
    return nil
  }

  public var method: Moya.Method {
    switch self {
    case .createQRCode:
      return .post
    }
  }

  public var parameters: [String : Any]? {
    switch self {
    case .createQRCode:
      return nil
    }
  }

  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
