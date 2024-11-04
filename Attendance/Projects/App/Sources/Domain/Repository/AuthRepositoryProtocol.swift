//
//  AuthRepositoryProtocol.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FirebaseAuth
import RxSwift

import Foundation

protocol AuthRepositoryProtocols {
    func auth(_ credential: AuthCredential) -> Single<AuthDataResult>
}
