//
//  YesNoAnswer.swift
//  DDDDesignKit
//
//  Created by Roy on 6/10/26.
//

import Foundation

/// 예/아니오 단일 선택 응답 값.
public enum YesNoAnswer: String, CaseIterable, Identifiable {
  case yes
  case no

  public var id: String { rawValue }

  public var title: String {
    switch self {
    case .yes: return "예"
    case .no: return "아니오"
    }
  }
}
