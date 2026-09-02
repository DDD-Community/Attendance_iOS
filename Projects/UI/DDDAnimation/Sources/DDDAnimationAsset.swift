//
//  DDDAnimationAsset.swift
//  DDDAnimation
//
//  Created by DDD on 9/1/26.
//

import Foundation

/// 애니메이션 에셋 토큰. rawValue 는 이 모듈 번들(`Resources/`)의 파일명과 일치한다.
public enum DDDAnimationAsset: String, Sendable, CaseIterable {
  /// 화면 전환·데이터 로딩 중 보여주는 기본 로딩 애니메이션.
  case loading = "DDDLoding.gif"
}
