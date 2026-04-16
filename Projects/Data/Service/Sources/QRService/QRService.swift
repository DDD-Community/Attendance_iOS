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
  case qrAttendanceCheck(qrCode: String)
  case createQRCode(userID: Int)
}

extension QRService: BaseTargetType {
  public typealias Domain = AttendanceDomain
  
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
      return QRAPI.validate.description
    case .createQRCode(let userID):
      return "/\(userID)/qr"
    }
  }
  
  public var method: Moya.Method {
    switch self{
    case .qrAttendanceCheck:
      return .post
    case .createQRCode:
      return .get
    }
  }
  
  public var parameters: [String: Any]? {
    switch self {
    case .qrAttendanceCheck(let qrCode):
      return qrCode.toDictionary(key: "qrCode")
    case .createQRCode(let userID):
      return ["id": userID]
    }
  }
  
  public var headers: [String: String]? {
    return APIHeader.baseHeader
  }
  
  public var error: [Int: AsyncMoya.NetworkError]? {
    return nil
  }
}
