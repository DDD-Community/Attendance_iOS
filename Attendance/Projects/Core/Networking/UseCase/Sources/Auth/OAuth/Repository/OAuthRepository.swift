//
//  OAuthRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 10/30/24.
//

import AsyncMoya
import Model
import AuthenticationServices
import FirebaseAuth
import GoogleSignIn
import Firebase
import ComposableArchitecture
import SwiftUI

@Observable
public class OAuthRepository: OAuthRepositoryProtocol {
  let fireBaseDB = Firestore.firestore()
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
  ) async throws -> OAuthResponseDTOModel? {
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
          continuation.resume(returning: result?.user)
        }
      }
    }
    
    guard authResult != nil else {
      throw NSError(domain: "FirebaseAuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user information."])
    }
    let oauthResponseModel = OAuthResponseModel(
      accessToken: accessToken,
      refreshToken: "",
      credential: firebaseCredential,
      email: fullName.email ?? ""
    )
    
    return oauthResponseModel.toDTOModel()
  }
  
  //MARK: - 구글 로그인
  public func googleLogin() async throws -> OAuthResponseDTOModel? {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return nil }
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.main.async {
        GIDSignIn.sharedInstance.signIn(withPresenting: GoogleLoginManger.shared.getRootViewController()) { user, error in
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
              let tokenResponse = OAuthResponseModel(
                accessToken: accessToken,
                refreshToken: "",
                credential: firebaseCredential,
                email: result?.user.email ?? ""
              )
              continuation.resume(returning: tokenResponse.toDTOModel())
            }
          }
        }
      }
    }
  }
  
  //MARK: - 유저 조회
  //MARK: - 회원가입 한  유저 조회
  public func fetchUser(uid: String) async throws -> UserDTOMember? {
    let userRef = fireBaseDB.collection(FireBaseCollection.member.desc).whereField("email", isEqualTo: uid)
    
    do {
      let querySnapshot = try await userRef.getDocuments()
      guard let document = querySnapshot.documents.first else {
        throw UserRepositoryError.memberNotExist
      }
      
      let data = document.data()
      let uids: String = data["uid"] as? String ?? ""
      let name: String = data["name"] as? String ?? ""
      let email: String = data["email"] as? String ?? ""
      let memberid: String = data["memberid"] as? String ?? ""
      let createdAt: Date = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
      let updatedAt: Date = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
      let generation: Int = data["generation"] as? Int ?? 0
      let memberType: MemberType = MemberType(rawValue: data["memberType"] as? String ?? "") ?? .member
      let managing: Managing = Managing(rawValue: data["manging"] as? String ?? "") ?? .notManging
      let memberTeam: SelectTeam = SelectTeam(rawValue: data["memberTeam"] as? String ?? "") ?? .notTeam
      let roleType: SelectPart = SelectPart(rawValue: data["role"] as? String ?? "") ?? .all
      let isAdmin: Bool = data["isAdmin"] as? Bool ?? false
      
      let user = Member(
        uid: uids,
        memberid: memberid,
        email: email,
        name: name,
        role: roleType,
        memberType: memberType,
        manging: managing,
        memberTeam: memberTeam,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isAdmin: isAdmin,
        generation: generation
      )
      
      return user.toUserMember()
    } catch {
      throw UserRepositoryError.memberNotExist
    }
  }
}
