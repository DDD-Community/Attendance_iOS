//
//  SignUpRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Model

import Combine
import FirebaseFirestore
import AsyncMoya

@Observable
public class SignUpRepository: SignUpRepositoryProtcol {
  let fireBaseDB = Firestore.firestore()
  
  public init() {
    
  }
  
  
  public func validateInviteCode(
      code: String
  ) async throws -> InviteDTOModel? {
      let inviteCodeRef = fireBaseDB.collection(FireBaseCollection.inviteCode.desc)
      
      do {
          let querySnapshot = try await inviteCodeRef.whereField("code", isEqualTo: code).getDocuments()
          guard let document = querySnapshot.documents.first else {
              throw UserRepositoryError.invalidInviteCode
          }
          
          let data = document.data()
          guard let timeStamp = data["expired_date"] as? Timestamp,
                timeStamp.seconds > Int(Date().timeIntervalSince1970),
                let isAdmin = data["is_admin"] as? Bool else {
              throw UserRepositoryError.invalidInviteCode
          }
        #logDebug("초대코드 확인", data)
        
        return InviteDTOModel(code: code, expireData:  timeStamp.dateValue(), isAdmin: isAdmin)
      } catch {
          throw UserRepositoryError.invalidInviteCode
      }
  }
}
