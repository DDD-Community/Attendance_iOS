//
//  SplashFixture.swift
//  SplashTesting
//
//  Created by DDD on 2026-09-02
//
//  Splash 전용 테스트 더블.
//
//  도메인 엔티티 픽스처는 EntityTesting 의 EntityFixture 에 있다.
//  여기 다시 두면 같은 값이 두 곳에 생겨 필드 변경 시 양쪽을 고쳐야 한다.
//

import DomainInterface
import Entity
import EntityTesting

/// 항상 같은 결과만 돌려주는 앱 업데이트 스텁.
/// Splash 는 실행 즉시 업데이트를 확인하므로 테스트·데모에서 이 더블이 필요하다.
public struct StubAppUpdateRepository: AppUpdateInterface {
  private let info: AppUpdateInfo

  public init(info: AppUpdateInfo = EntityFixture.upToDate) {
    self.info = info
  }

  public func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo {
    info
  }
}
