//
//  SelectJob.swift
//  Entity
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation

public struct SelectJob: Equatable {
  public let jobKeys: String
  public let job: SelectParts

  public init(
    jobKeys: String,
    job: SelectParts
  ) {
    self.jobKeys = jobKeys
    self.job = job
  }
}
