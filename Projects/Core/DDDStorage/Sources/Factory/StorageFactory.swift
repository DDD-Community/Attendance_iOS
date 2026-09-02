//
//  StorageFactory.swift
//  DDDStorage
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface

public enum StorageFactory {
  public static var secureStorage: any SecureStorage {
    return KeychainStorage()
  }
}
