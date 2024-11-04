//
//  AuthRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import Model
import AsyncMoya
import FirebaseFirestore

@Observable
public class AuthRepository: AuthRepositoryProtocol {
  
  let fireBaseDB = Firestore.firestore()
  public init() {}
  
  
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
