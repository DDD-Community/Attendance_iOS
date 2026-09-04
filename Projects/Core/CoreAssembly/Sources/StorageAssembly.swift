//
//  StorageAssembly.swift
//  CoreAssembly
//
//  Created by DDD on 9/1/26.
//

import DDDStorage
import DDDStorageInterface

public enum StorageAssembly {
  public static func secureStorage() -> any SecureStorage {
    return StorageFactory.secureStorage
  }

  public static func sharedValueStorage() -> any SharedValueStorage {
    return StorageFactory.sharedValueStorage
  }
}
