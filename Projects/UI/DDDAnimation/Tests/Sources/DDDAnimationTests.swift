//
//  DDDAnimationTests.swift
//  DDDAnimationTests
//
//  Created by DDD on 9/1/26.
//

import Foundation
import Testing

@testable import DDDAnimation

@Suite("DDDAnimation")
struct DDDAnimationTests {
  @Test("모든 에셋이 모듈 번들에 실제로 존재한다", arguments: DDDAnimationAsset.allCases)
  func assetExistsInBundle(_ asset: DDDAnimationAsset) {
    let name = (asset.rawValue as NSString).deletingPathExtension
    let ext = (asset.rawValue as NSString).pathExtension
    #expect(Bundle.module.url(forResource: name, withExtension: ext) != nil)
  }
}
