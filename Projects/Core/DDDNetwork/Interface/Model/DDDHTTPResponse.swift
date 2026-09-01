//
//  DDDHTTPResponse.swift
//  DDDNetworkInterface
//
//  Created by DDD on 9/1/26.
//

import Foundation

public struct DDDHTTPResponse: Sendable, Equatable {
  public let statusCode: Int
  public let data: Data

  public init(statusCode: Int, data: Data) {
    self.statusCode = statusCode
    self.data = data
  }
}
