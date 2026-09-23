//
//  BaseResponseDomain.swift
//  DDDNetworkInterface
//
//  Created by DDD on 8/5/25.
//

import Foundation

/// 1) 공용 응답 래퍼
public struct BaseResponseDomain<T: Equatable>: Equatable {
  public let code: Int?
  public let message: String?
  public let data: T

  public init(
    code: Int?,
    message: String?,
    data: T
  ) {
    self.code = code
    self.message = message
    self.data = data
  }

}
