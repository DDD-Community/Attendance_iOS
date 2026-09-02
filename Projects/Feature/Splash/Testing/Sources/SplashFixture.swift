//
//  SplashFixture.swift
//  SplashTesting
//
//  Splash 테스트·데모가 공유하는 고정 데이터.
//  각 테스트가 같은 엔티티를 다시 만들면 필드가 늘어날 때마다 흩어진 정의를 모두 고쳐야 한다.
//
//  Splash.State 팩토리는 두지 않는다. State 의 프로퍼티가 internal 이라
//  @testable 없이는 접근할 수 없고, 픽스처 하나 때문에 State 를 public 으로
//  넓히는 건 대가가 크다. 상태 조립은 @testable 을 쓸 수 있는 테스트 쪽에 남긴다.
//

import Entity

public enum SplashFixture {
  public static let memberProfile = ProfileEntity(
    userID: 1,
    name: "김철수",
    generation: "2기",
    team: .ios1,
    jobRole: .ios,
    role: .member,
    manger: nil
  )

  public static let updateAvailable = AppUpdateInfo(
    currentVersion: "1.0.0",
    latestVersion: "1.2.3",
    releaseNotes: "[v 1.2.3]\n- bug fixes",
    appStoreUrl: "https://apps.apple.com/app/id123",
    isUpdateAvailable: true
  )
}
