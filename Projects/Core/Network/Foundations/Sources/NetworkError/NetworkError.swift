//
//  NetworkError.swift
//  Foundations
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

import Moya

public enum NetworkError: Error {
  case underlying(MoyaError)
  case invalidResponse(statusCode: Int, message: String)
  case noData
  case decodingError(Error)
}
