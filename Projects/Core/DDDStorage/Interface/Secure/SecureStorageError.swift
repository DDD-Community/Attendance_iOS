//
//  SecureStorageError.swift
//  DDDStorageInterface
//
//  Created by DDD on 9/1/26.
//

import Foundation

public enum SecureStorageError: Error {
  case invalidData
  case unexpectedStatus(OSStatus)
}
