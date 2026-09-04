//
//  MemberMainViewRenderTests.swift
//  MemberTests
//
//  Created by DDD on 9/4/26.
//

import ComposableArchitecture
import Testing

@testable import Member

@MainActor
@Suite("MemberMainView 렌더링")
struct MemberMainViewRenderTests {
  @Test("멤버 홈 로딩 상태는 skeleton을 렌더링한다")
  func rendersLoadingSkeleton() {
    var state = MemberMain.State()
    state.didAppear = true
    state.viewState = .loading

    MemberViewRenderer.render(
      MemberMainView(
        store: Store(initialState: state) {
          MemberMain()
        }
      )
    )
  }

  @Test("멤버 홈 skeleton을 단독으로 렌더링한다")
  func rendersSkeletonView() {
    MemberViewRenderer.render(MemberMainSkeletonView())
  }
}
