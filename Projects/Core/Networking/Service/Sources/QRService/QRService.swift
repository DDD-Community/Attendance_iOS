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
}


extension QRService : BaseTargetType {
  public var domain: AttandanceDomain {
    return .qr
  }
  
  public var urlPath: String {
    switch self {
    case .qrAttendanceCheck:
      return QRAPI.qrcodeValidate.qrcodeDescription
    }
  }
  
  public var method: Moya.Method {
    switch self{
    case .qrAttendanceCheck:
      return .post
    }
  }
  
  public var parameters: [String : Any]? {
    switch self {
    case .qrAttendanceCheck(let code):
      let parameters: [String: Any] = ["qr_string": code]
      return parameters
    }
  }
  
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
  
  public var error: [Int : Foundations.NetworkError]? {
    return nil
  }
}
