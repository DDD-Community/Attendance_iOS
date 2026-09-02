//
//  TokenDTO.swift
//  Model
//
//  Created by DDD on 1/2/26.
//

import Foundation

public struct TokenDTO: Decodable, Sendable {
    let accessToken, refreshToken: String
}
