//
//  Extension+MoyaProvider+Auth.swift
//  Repository
//
//  Created by Wonji Suh  on 1/2/26.
//

import AsyncMoya

public extension MoyaProvider {
  static var authorized: MoyaProvider<Target> {
    MoyaProvider(
      session: AuthSessionManager.shared.session,
      plugins: [
        MoyaLoggingPlugin()
      ]
    )
  }
}
