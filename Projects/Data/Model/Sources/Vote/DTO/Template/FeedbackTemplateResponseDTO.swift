//
//  FeedbackTemplateResponseDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [멤버] 피드백 템플릿 응답 (GET /votes/{id}/feedback/template)

public struct FeedbackTemplateResponseDTO: Decodable, Sendable {
  public let templateVersion: Int?
  public let status: String?
  public let template: FeedbackTemplateDTO?
}
