//
//  NetworkAssembly.swift
//  CoreAssembly
//
//  Created by DDD on 9/1/26.
//

import DDDNetwork
import DDDNetworkInterface

public enum NetworkAssembly {
  public static func plainClient() -> any DDDNetworkClient {
    return NetworkClientFactory.plain()
  }
}
