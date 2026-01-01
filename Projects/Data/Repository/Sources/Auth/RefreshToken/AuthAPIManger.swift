//
//  AuthAPIManger.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/22/25.
//

import Foundation
import Model
import AsyncMoya
import Foundation
import API
import Alamofire
import Foundations
import ComposableArchitecture


//public final actor AuthAPIManger {
//  public static let shared = AuthAPIManger()
//  var loginModel: LoginModel? = nil
//  @Shared(.inMemory("UserEntity")) var userEntity: UserEntity = .shared
//
//  let repository = AuthRepositoryImpl()
//
//  public init() {}
//
//  public func refeshTokenRsponse(_ result: Result<LoginModel, CustomError>) -> Result<LoginModel, CustomError>  {
//    switch result {
//    case .success(let refeshModel):
//      self.loginModel = refeshModel
//      APIHeader.accessTokenKeyChain = refeshModel.data.accessToken
//      UserDefaults.standard.set(refeshModel.data.accessToken, forKey: "ACCESS_TOKEN")
//      return .success(refeshModel)
//    case .failure(let error):
//      Log.error("리프레쉬 에러", error.localizedDescription)
//      return .failure(error)
//    }
//  }
//
//  public func getRefeshToken() async  -> RetryResult  {
//    let authResultData = await Result {
//      try await repository.loginUser(email: userEntity.userEmail)
//    }
//
//    switch authResultData {
//    case .success(let authResultData):
//      if let authResultData = authResultData{
//        _ =  self.refeshTokenRsponse(.success(authResultData)) // 반환 값을 무시
//        return .retry
//      } else {
//        // authResultData가 nil일 경우
//        let error = CustomError.unknownError("AuthResultData is nil")
//        _ = refeshTokenRsponse(.failure(error))
//        return .doNotRetryWithError(error)
//      }
//
//    case .failure(let error):
//      _ =  refeshTokenRsponse(.failure(CustomError.unknownError(error.localizedDescription))) // 반환 값을 무시
//      return .doNotRetryWithError(error)
//    }
//  }
//}
