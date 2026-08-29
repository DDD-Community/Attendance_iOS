//
//  TeamVoteCategoryDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct TeamVoteCategoryDTO: Codable {
  public let id: String?
  public let order: Int?
  public let title: String?
  public let maxSelectableTeams: Int?
  public let reasonRequired: Bool?
  public let reasonMinLength: Int?
  public let reasonMaxLength: Int?
  public let reasonLabel: String?
}
