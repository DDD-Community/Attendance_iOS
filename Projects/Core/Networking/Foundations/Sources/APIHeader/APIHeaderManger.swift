//
//  APIHeaderManger.swift
//  Foundations
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

public struct APIHeaderManger {
  public static let shared = APIHeaderManger()
  
  public init() {}
  
  let appPackageName: String = "-"
  let contentType: String = "application/json"
  let multipartContentType: String = "multipart/form-data"
  let contentAppleType: String = "application/x-www-form-urlencoded"
  let csrf: String = "BNazqxDLBzmlYFKCwAMMJYNcmkAq6kAt"
}
