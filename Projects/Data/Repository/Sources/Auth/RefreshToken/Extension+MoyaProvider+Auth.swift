//
//  Extension+MoyaProvider+Auth.swift
//  Repository
//
//  Created by Wonji Suh  on 1/2/26.
import ThirdPartys

public extension MoyaProvider {
  static var authorized: MoyaProvider<Target> {
    let manager = AuthSessionManager.shared

    return MoyaProvider(
      session: manager.session,
      plugins: [
        MoyaLoggingPlugin()
      ]
    )
  }
}
