//
//  FeedbackTemplateInfo.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [멤버] 피드백 템플릿 응답

public struct FeedbackTemplateInfo: Equatable, Sendable {
  public let templateVersion: Int
  public let status: VoteStatus
  public let template: FeedbackTemplate

  public init(
    templateVersion: Int,
    status: VoteStatus,
    template: FeedbackTemplate
  ) {
    self.templateVersion = templateVersion
    self.status = status
    self.template = template
  }
}
