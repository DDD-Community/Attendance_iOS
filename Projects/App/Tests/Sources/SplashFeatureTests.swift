//
//  SplashFeatureTests.swift
//  DDDAttendanceTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import DomainInterface
import EntityTesting
import FeatureAssembly
import Testing

@testable import DDDAttendance

@MainActor
@Suite("SplashFeature")
struct SplashFeatureTests {
  @Test("업데이트가 없고 멤버 프로필 fetch가 끝났으면 멤버 화면으로 이동한다")
  func upToDateMemberNavigatesToMemberAfterProfileFetch() async {
    var state = SplashFeature.State()
    state.staffRole = .member
    state.profileModel = EntityFixture.memberProfile
    state.profileFetchCompleted = true

    let store = TestStore(initialState: state) {
      SplashFeature()
    }

    await store.send(.inner(.checkAppUpdateResponse(.success(nil)))) {
      $0.isUpdateCheckCompleted = true
    }
    await store.receive(\.delegate.presentMember)
  }

  @Test("업데이트가 필요하면 앱스토어 URL을 저장하고 업데이트 팝업을 표시한다")
  func updateAvailablePresentsUpdateAlert() async {
    let store = TestStore(initialState: SplashFeature.State()) {
      SplashFeature()
    }

    await store.send(.inner(.checkAppUpdateResponse(.success(EntityFixture.updateAvailable)))) {
      $0.isUpdateCheckCompleted = true
      $0.appStoreUrl = "https://apps.apple.com/app/id123"
      $0.customAlert = .alert(
        title: "새로운 버전이 출시되었어요!",
        message: "새로운 버전 1.2.3이 출시되었습니다!\n\n더 나은 경험을 위해 지금 업데이트하세요!",
        confirmTitle: "지금 업데이트",
        cancelTitle: "나중에 할게요",
        isDestructive: false
      )
    }
  }

  @Test("프로필 조회 실패는 저장된 인증 정보를 지우고 로그인 화면으로 이동한다")
  func profileFetchFailureClearsKeychainAndNavigatesToLogin() async {
    let keychain = KeychainSpy()
    let store = TestStore(initialState: SplashFeature.State()) {
      SplashFeature()
    } withDependencies: {
      $0.keychainManager = keychain
    }

    await store.send(.inner(.fetchUserResponse(.failure(.invalidSession))))
    await store.receive(\.delegate.presentLogin)
    #expect(keychain.didClear)
  }

  @Test("업데이트 팝업 취소 시 프로필 fetch가 끝났으면 현재 역할에 맞춰 이동한다")
  func cancelUpdateAlertNavigatesAfterProfileFetchCompleted() async {
    var state = SplashFeature.State()
    state.staffRole = .manager
    state.customAlert = .alert(
      title: "새로운 버전이 출시되었어요!",
      message: "업데이트가 필요합니다.",
      confirmTitle: "지금 업데이트",
      cancelTitle: "나중에 할게요",
      isDestructive: false
    )
    state.profileFetchCompleted = true

    let store = TestStore(initialState: state) {
      SplashFeature()
    }

    await store.send(.scope(.customAlert(.presented(.cancelTapped)))) {
      $0.customAlert = nil
    }
    await store.receive(\.delegate.presentStaff)
  }
}

private extension SplashFeatureTests {

}

private final class KeychainSpy: KeychainManaging, @unchecked Sendable {
  private(set) var didClear = false

  func save(accessToken _: String, refreshToken _: String) {}
  func saveAccessToken(_: String) {}
  func saveRefreshToken(_: String) {}
  func accessToken() -> String? { nil }
  func refreshToken() -> String? { nil }

  func clear() {
    didClear = true
  }
}
