//
//  OAuthRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 10/30/24.
//

import AuthenticationServices
import SwiftUI

import Model

import AsyncMoya
import ComposableArchitecture
import Firebase
import FirebaseAuth
import GoogleSignIn

@Observable
public class OAuthRepository: OAuthRepositoryProtocol {
  private let fireBaseDB = Firestore.firestore()
  @Shared(.inMemory("UseEntity"))
    private static var internalUserEntity: UserEntity = .init()

    // 2️⃣ Expose it via an instance computed property:
    public var userEntity: UserEntity {
      get {
        // read under lock
        return Self.$internalUserEntity.withLock { $0 }
      }
      set {
        // write under lock
        Self.$internalUserEntity.withLock { $0 = newValue }
      }
    }
  
  public init() {}
  
  public func handleAppleLogin(
    _ requestResult: Result<ASAuthorization, any Error>,
    nonce: String
  ) async throws -> ASAuthorization {
    switch requestResult {
    case .success(let authResults):
      switch authResults.credential {
      case let appleIDCredential as ASAuthorizationAppleIDCredential:
        if let tokenData = appleIDCredential.identityToken,
           let acessToken = String(data: tokenData, encoding: .utf8),
           let authorizationCode = appleIDCredential.authorizationCode{
          do {
            let code = String(decoding: authorizationCode, as: UTF8.self)
            #logNetwork(acessToken, authorizationCode)
            UserDefaults.standard.set(code, forKey: "APPLE_ACCESS_CODE")
            UserDefaults.standard.set(acessToken, forKey: "APPLE_ACCESS_TOKEN")
            
            _ = try await self.appleLoginWithFireBase(withIDToken: acessToken, rawNonce: nonce, fullName: appleIDCredential)
            
          } catch {
            throw error
          }
        } else {
          Log.error("Identity token is missing")
          throw DataError.noData
        }
        return authResults
      default:
        throw DataError.decodingError(NSError(domain: "Invalid Credential", code: 0, userInfo: nil))
      }
      
    case .failure(let error):
      Log.error("Error: \(error.localizedDescription)")
      throw error
    }
  }
  
  public func appleLoginWithFireBase(
    withIDToken: String,
    rawNonce: String,
    fullName: ASAuthorizationAppleIDCredential
  ) async throws -> OAuthResponseModel? {
    let firebaseCredential = OAuthProvider.appleCredential(
      withIDToken: withIDToken,
      rawNonce: rawNonce,
      fullName: fullName.fullName
    )
    
    let accessToken = UserDefaults.standard.string(forKey: "APPLE_ACCESS_TOKEN") ?? ""
    // 비동기 로그인 시 오류 처리를 위해 async/await를 사용
    let authResult: User? = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User?, Error>) in
      Auth.auth().signIn(with: firebaseCredential) { result, error in
        if let error = error {
          #logError("[🔥] 로그인에 실패하였습니다 \(error.localizedDescription)")
          continuation.resume(throwing: error)
        } else {
          UserDefaults.standard.set(result?.user.email ?? "", forKey: "UserEmail")
          UserDefaults.standard.set(result?.user.uid ?? "", forKey: "UserUID")
          continuation.resume(returning: result?.user)
        }
      }
    }
    
    guard authResult != nil else {
      throw NSError(domain: "FirebaseAuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user information."])
    }
    let uid = UserDefaults.standard.string(forKey: "UserUID") ?? ""
    let oauthResponseModel = OAuthResponseDTOModel(
      accessToken: accessToken,
      refreshToken: "",
      credential: firebaseCredential,
      email: fullName.email ?? "",
      uid: uid
    )
    
    
    self.userEntity.userUid = uid
    self.userEntity.userEmail = fullName.email ?? ""
    self.userEntity.userName = fullName.fullName?.givenName ?? ""
   
    
    return oauthResponseModel.toDomain()
  }
  
  // MARK: - 구글 로그인
  
  public func googleLogin() async throws -> OAuthResponseModel? {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return nil }
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.main.async {
        GIDSignIn.sharedInstance.signIn(withPresenting: GoogleLoginManager.shared.getRootViewController()) { user, error in
          if let error = error {
            #logError("[🔥] 로그인에 실패하였습니다 \(error.localizedDescription)")
            continuation.resume(throwing: error)
            return
          }
          
          guard let user = user else {
            continuation.resume(throwing: NSError(domain: "GoogleLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is nil"]))
            return
          }
         
          let accessToken: String = user.user.idToken?.tokenString ?? ""
          let firebaseCredential = GoogleAuthProvider.credential(
            withIDToken: accessToken,
            accessToken: user.user.accessToken.tokenString
          )
          
          Auth.auth().signIn(with: firebaseCredential) { result, error in
            if let error = error {
              #logError("[🔥] 로그인에 실패하였습니다 \(error.localizedDescription)")
              continuation.resume(throwing: error)
            } else {
              let tokenResponse = OAuthResponseDTOModel(
                accessToken: accessToken,
                refreshToken: "",
                credential: firebaseCredential,
                email: result?.user.email ?? "",
                uid: result?.user.uid ?? ""
              )
              UserDefaults.standard.set(result?.user.email ?? "", forKey: "UserEmail")
              continuation.resume(returning: tokenResponse.toDomain())
            }
          }
        }
      }
    }
  }
}
