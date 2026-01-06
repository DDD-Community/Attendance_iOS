//
//  TokenDTO.swift
//  Model
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation

public struct TokenDTO: Decodable {
    let accessToken, refreshToken: String
}
