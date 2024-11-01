//
//  OAuthError.swift
//  Model
//
//  Created by Wonji Suh  on 11/1/24.
//

import Foundation

public enum OAuthError: Error {
    case googleLoginError
    case appleLoginError
    case firebaseLoginError
}
