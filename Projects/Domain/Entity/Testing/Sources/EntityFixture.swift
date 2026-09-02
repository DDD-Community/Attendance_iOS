//
//  EntityFixture.swift
//  EntityTesting
//
//  Created by DDD on 2026-09-02
//
//  테스트가 공유하는 도메인 엔티티 픽스처.
//  같은 엔티티를 테스트마다 다시 만들면 필드가 추가될 때 흩어진 정의를 모두 고쳐야 한다.
//  실제로 memberProfile 은 Profile 과 Splash 테스트에 똑같이 중복 정의되어 있었다.
//  Entity 는 의존성이 없고 모든 계층이 공유하므로 픽스처도 여기 한 곳에 둔다.
//

import Entity
import Foundation

public enum EntityFixture {

  // MARK: - Profile

  public static let memberProfile = ProfileEntity(
    userID: 1,
    name: "김철수",
    generation: "2기",
    team: .ios1,
    jobRole: .ios,
    role: .member,
    manger: nil
  )

  // MARK: - Schedule

  public static let schedule = Schedule(
    id: 1,
    name: "OT",
    description: "오리엔테이션",
    month: 9,
    day: 2,
    year: 2026
  )

  // MARK: - AppUpdate

  public static let updateAvailable = AppUpdateInfo(
    currentVersion: "1.0.0",
    latestVersion: "1.2.3",
    releaseNotes: "[v 1.2.3]\n- bug fixes",
    appStoreUrl: "https://apps.apple.com/app/id123",
    isUpdateAvailable: true
  )

  public static let upToDate = AppUpdateInfo(
    currentVersion: "1.2.3",
    latestVersion: "1.2.3",
    releaseNotes: "",
    appStoreUrl: "https://apps.apple.com/app/id123",
    isUpdateAvailable: false
  )
}
