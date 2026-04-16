//
//  Extension+MoyaProvider+Response.swift
//  Repository
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation
import ThirdPartys
import Moya

public extension MoyaProvider {
  func requestResponse(_ target: Target) async throws -> Response {
    try await withCheckedThrowingContinuation { continuation in
      request(target) { result in
        continuation.resume(with: result)
      }
    }
  }
}
