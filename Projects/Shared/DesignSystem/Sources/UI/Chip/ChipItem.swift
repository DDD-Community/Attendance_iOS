//
//  ChipItem.swift
//  DesignSystem
//
//  Created by Roy on 6/10/26.
//

import Foundation

/// 서버에서 내려오는 커리큘럼/선택지 한 개를 표현하는 칩 데이터 모델.
public struct ChipItem: Identifiable, Equatable, Hashable {
  public let id: String
  public let title: String

  public init(id: String, title: String) {
    self.id = id
    self.title = title
  }
}
