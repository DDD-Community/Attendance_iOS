//
//  GoogleOAuthConfiguration.swift
//  AuthDomain
//
//  Created by DDD on 12/29/25.
//

import Foundation

public struct GoogleOAuthConfiguration {
    public let clientID: String
    public let serverClientID: String

    public static var current: GoogleOAuthConfiguration {
        let clientID = "\(Bundle.main.object(forInfoDictionaryKey: "GOOGLE_IOS_CLIENT_ID") as? String ?? "")"
        let serverClientID = "\(Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String ?? "")"
        return GoogleOAuthConfiguration(clientID: clientID, serverClientID: serverClientID)
    }

    public var isValid: Bool {
        !clientID.contains("YOUR_GOOGLE_IOS_CLIENT_ID") &&
        !serverClientID.contains("GOOGLE_CLIENT_ID")
    }

    public init(clientID: String, serverClientID: String) {
        self.clientID = clientID
        self.serverClientID = serverClientID
    }
}

