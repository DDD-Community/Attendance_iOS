//
//  DDDMultipartPart.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 멀티파트 바디의 한 조각. (파일 또는 폼 필드)
/// Alamofire 의 `MultipartFormData` 를 노출하지 않고 "무엇을 보낼지"만 데이터로 표현한다.
public struct DDDMultipartPart: Sendable {
  /// 파트 소스 — 메모리 데이터 또는 스트리밍할 파일 URL
  public enum Source: Sendable {
    case data(Data)
    case file(URL)
  }

  /// 폼 필드명 (예: "image", "title")
  public let name: String
  public let source: Source
  /// 파일명 (파일 파트일 때)
  public let fileName: String?
  /// MIME 타입 (예: "image/jpeg")
  public let mimeType: String?

  public init(
    name: String,
    source: Source,
    fileName: String? = nil,
    mimeType: String? = nil
  ) {
    self.name = name
    self.source = source
    self.fileName = fileName
    self.mimeType = mimeType
  }
}
