//
//  NonParticipant+Placeholder.swift
//  Management
//
//  Created by Roy on 6/11/26.
//

import Entity

// TODO: API 연동 후 제거 — GET /votes/{id}/non-responders 응답으로 대체
extension NonParticipant {
  static let placeholders: [NonParticipant] = [
    .init(id: 1, name: "김민준", teamName: "Web 1팀", attendance: .absent),
    .init(id: 2, name: "이서연", teamName: "Web 2팀", attendance: .late),
    .init(id: 3, name: "박지호", teamName: "iOS 1팀", attendance: .attended),
    .init(id: 4, name: "최유나", teamName: "iOS 2팀", attendance: .attended),
    .init(id: 5, name: "정우진", teamName: "Android 1팀", attendance: .late),
    .init(id: 6, name: "한소희", teamName: "Android 2팀", attendance: .absent),
    .init(id: 7, name: "오현우", teamName: "iOS 2팀", attendance: .attended)
  ]
}
