//
//  Extension+Encodable.swift
//  Service
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation

extension Encodable {
  var toDictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
  }
}

