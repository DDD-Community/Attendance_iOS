//
//  QRService.swift
//  Service
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

import API
import Foundations

import AsyncMoya

public enum QRService {
  case qrAttendanceCheck(code: String)
  case createQRCode
}

extension QRService: BaseTargetType {
  public var domain: AttendanceDomain {
    switch self {
    case .qrAttendanceCheck:
      return .attendance
    case .createQRCode:
      return .qr
    }
  }
  
  public var urlPath: String {
    switch self {
    case .qrAttendanceCheck:
      return QRAPI.qrcodeValidate.qrcodeDescription
    case .createQRCode:
      return ""
    }
  }
  
  public var method: Moya.Method {
    switch self{
    case .qrAttendanceCheck:
      return .post
    case .createQRCode:
      return .post
    }
  }
  
  public var parameters: [String: Any]? {
    switch self {
    case .qrAttendanceCheck(let code):
      let parameters: [String: Any] = ["qr_code_value": code]
      return parameters
    case .createQRCode:
      return nil
    }
  }
  
  public var headers: [String: String]? {
    return APIHeader.baseHeader
  }
  
  public var error: [Int: Foundations.NetworkError]? {
    return nil
  }

  public var validationType: ValidationType {
    switch self {
    case .qrAttendanceCheck(let code):
      return .customCodes(Array(200...410))
    case .createQRCode:
      return .successCodes
    }
  }
}
