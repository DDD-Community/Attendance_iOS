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
  
  //MARK: - 초대 코드 확인
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
          
          // `InviteModel`을 초기화하고 `toModel()`을 사용하여 변환
          let inviteModel = InviteModel(
              code: code,
              expiredDate: timeStamp.dateValue(),
              isAdmin: isAdmin
          )
          
          return inviteModel.toModel()
      } catch {
          throw UserRepositoryError.invalidInviteCode
      }
  }
  
  //MARK: - 운영진  회원가입
  public func signUpCoreMember(
    member: Member
  ) async throws -> CoreMemberDTOSignUp? {
    
    let userRef = fireBaseDB.collection(FireBaseCollection.member.desc).document(member.uid)
    var data = member.toCoreMemberDictionary()
    
    do {
        try await userRef.setData(data)
      #logDebug("운영진 회원가입: \(userRef.documentID)")
      return member.toCoreMembersModel()
    } catch {
        #logError("운영진 회원가입 실패 \(error)")
        throw CustomError.unknownError("Error adding document: \(error.localizedDescription)")
    }
  }
  
  //MARK: - 멤버 회원가입
  
  public func signUpMember(member: Member) async throws -> MemberDTOSignUp? {
    let userRef = fireBaseDB.collection(FireBaseCollection.member.desc).document(member.uid)
    var data = member.toMemberDictionary()
    
    do {
        try await userRef.setData(data)
      #logDebug("멤버 회원가입: \(userRef.documentID)")
      return member.toMembersModel()
    } catch {
        #logError("멤버 회원가입 실패 \(error)")
        throw CustomError.unknownError("Error adding document: \(error.localizedDescription)")
    }
  }
}
