//
//  AuthInterceptor.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/22/25.
//

import Alamofire
import AsyncMoya
import Foundation
import API

public final actor AuthInterceptor: RequestInterceptor {
  public static let shared = AuthInterceptor()

  private init() {}

  // Request를 수정하여 토큰을 추가하는 메서드
  public nonisolated func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping (Result<URLRequest, Error>) -> Void
  ) async {
    guard urlRequest.url?.absoluteString.hasPrefix(BaseAPI.base.apiDescription) == true else {
      completion(.success(urlRequest))
      return
    }

    // Retrieve the access token from the Keychain
    let accessToken = UserDefaults.standard.string(forKey: "ACCESS_TOKEN")
    var urlRequest = urlRequest

    // Set the token as the Authorization header
    urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization") // Ensure the correct format is used

    Log.debug("Adapted request with headers: ", urlRequest.headers)
    completion(.success(urlRequest))
  }

  public nonisolated func retry(
    _ request: Request,
    for session: Session,
    dueTo error: Error,
    completion: @escaping (RetryResult) -> Void) async {
      Log.debug("Entered retry function")
      typealias Task = _Concurrency.Task
      // error의 상세 정보를 확인
      if let afError = error.asAFError, afError.isResponseValidationError {
        Log.error("Response validation error detected.")
      } else {
        Log.error("Error is not responseValidationFailed: \(error)")
      }

      // 401 상태 코드 확인
      guard let response = request.task?.response as? HTTPURLResponse else {
        Log.debug("Response is not an HTTPURLResponse.")
        completion(.doNotRetryWithError(error))
        return
      }

      Log.debug("HTTP Status Code: \(response.statusCode)")

      switch response.statusCode {
      case 400, 401:
        Log.debug("401 Unauthorized detected, attempting to refresh token...")
        Task {
          let retryResult = await AuthAPIManger.shared.getRefeshToken()
          completion(retryResult)
        }
      default:
        Log.debug("Status code is not 401, not retrying.")
        completion(.doNotRetryWithError(error))
      }
    }
}
