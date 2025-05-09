//
//  SignUpRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Combine

import Model

import Service

import AsyncMoya
import Moya
import FirebaseFirestore

@Observable
public class SignUpRepository: SignUpRepositoryProtocol {
  
  private let fireBaseDB = Firestore.firestore()
  private let provider = MoyaProvider<SignUpService>(plugins: [MoyaLoggingPlugin()])
  
  public init() {}
  
  // MARK: - 초대 코드 확인
  
  public func validateInviteCode(
    code: String
  ) async throws -> InviteDTOModel? {
    return nil
  }
  
  // MARK: - 운영진 회원가입
  
  public func signUpCoreMember(
    member: Member
  ) async throws -> CoreMemberDTOSignUp? {
    
    let userRef = fireBaseDB.collection(FireBaseCollection.member.desc).document(member.uid)
    let data = member.toCoreMemberDictionary()
    
    do {
      try await userRef.setData(data)
      #logDebug("운영진 회원가입: \(userRef.documentID)")
      return member.toCoreMembersModel()
    } catch {
      #logError("운영진 회원가입 실패 \(error)")
      throw CustomError.unknownError("Error adding document: \(error.localizedDescription)")
    }
  }
  
  // MARK: - 멤버 회원가입
  
  public func signUpMember(member: Member) async throws -> MemberDTOSignUp? {
    let userRef = fireBaseDB.collection(FireBaseCollection.member.desc).document(member.uid)
    let data = member.toMemberDictionary()
    
    do {
      try await userRef.setData(data)
      #logDebug("멤버 회원가입: \(userRef.documentID)")
      return member.toMembersModel()
    } catch {
      #logError("멤버 회원가입 실패 \(error)")
      throw CustomError.unknownError("Error adding document: \(error.localizedDescription)")
    }
  }
  
  // Mark : -  API 회원가입
  
  public func registerAccount(
    userName: String,
    email: String,
    password: String
  ) async throws -> SignUpDTOModel? {
    let signUpModel = try await provider.requestAsync(
      .registerAccount(
        username: userName,
        email: email,
        password1: password,
        password2: password),
      decodeTo: SignUpModel.self)
    return signUpModel.toSIgnUpDTOModel()
  }
  
  // Mark : - 초대 코드 검증
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> SignUPInviteDTOModel? {
    let validateInviteCodeModel = try await provider.requestAsync(
      .verifyInviteCode(inviteCode: inviteCode), decodeTo: SignUpInviteCodeModel.self)
    return validateInviteCodeModel.toSignUpDTOInviteCodeModel()
  }
}
