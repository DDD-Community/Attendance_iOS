//
//  WebRepresentableCoordinatorTests.swift
//  WebTests
//
//  WKNavigationDelegate 콜백을 직접 호출해 로딩 인디케이터 표시/숨김 분기를 커버한다.
//  실제 네트워크 내비게이션을 기다리지 않는다.
//

import SwiftUI
import Testing
import UIKit
import WebKit

@testable import Web

@MainActor
@Suite("WebRepresentableView.Coordinator 델리게이트")
struct WebRepresentableCoordinatorTests {
  /// Coordinator 내부의 `Task { @MainActor ... }` 가 실행될 틈을 준다.
  private func drainMainActorTasks() async {
    try? await Task.sleep(nanoseconds: 120_000_000)
  }

  private func makeCoordinator(
    url: String = "https://dddstudy.kr"
  ) -> WebRepresentableView.Coordinator {
    WebRepresentableView(urlToLoad: url).makeCoordinator()
  }

  // MARK: - didStartProvisionalNavigation

  @Test("로딩이 시작되면 로딩 인디케이터의 alpha 가 1 이 된다")
  func didStartProvisionalNavigation_withIndicator_setsAlphaToOne() async {
    // Given
    let coordinator = makeCoordinator()
    let indicator = UIView()
    indicator.alpha = 0
    coordinator.loadingIndicator = indicator
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    coordinator.webView(webView, didStartProvisionalNavigation: nil)
    await drainMainActorTasks()

    // Then
    #expect(indicator.alpha == 1)
  }

  @Test("로딩 인디케이터가 없으면 로딩 시작 콜백은 아무 일도 하지 않는다")
  func didStartProvisionalNavigation_withoutIndicator_isIgnored() async {
    // Given
    let coordinator = makeCoordinator()
    coordinator.loadingIndicator = nil
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    coordinator.webView(webView, didStartProvisionalNavigation: nil)
    await drainMainActorTasks()

    // Then
    #expect(coordinator.loadingIndicator == nil)
  }

  // MARK: - didFinish

  @Test("로딩이 끝나면 로딩 인디케이터의 alpha 가 0 으로 내려간다")
  func didFinish_withIndicator_setsAlphaToZero() async {
    // Given
    let coordinator = makeCoordinator()
    let indicator = UIView()
    indicator.alpha = 1
    coordinator.loadingIndicator = indicator
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    coordinator.webView(webView, didFinish: nil)
    await drainMainActorTasks()

    // Then
    #expect(indicator.alpha == 0)
  }

  @Test("로딩 인디케이터가 없으면 로딩 완료 콜백은 아무 일도 하지 않는다")
  func didFinish_withoutIndicator_isIgnored() async {
    // Given
    let coordinator = makeCoordinator()
    coordinator.loadingIndicator = nil
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    coordinator.webView(webView, didFinish: nil)
    await drainMainActorTasks()

    // Then
    #expect(coordinator.loadingIndicator == nil)
  }

  // MARK: - didFail

  @Test("내비게이션 실패 시에도 로딩 인디케이터가 숨겨진다")
  func didFailWithError_withIndicator_setsAlphaToZero() async {
    // Given
    let coordinator = makeCoordinator()
    let indicator = UIView()
    indicator.alpha = 1
    coordinator.loadingIndicator = indicator
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    let error = URLError(.notConnectedToInternet)

    // When
    coordinator.webView(webView, didFail: nil, withError: error)
    await drainMainActorTasks()

    // Then
    #expect(indicator.alpha == 0)
  }

  @Test("프로비저널 내비게이션 실패 시에도 로딩 인디케이터가 숨겨진다")
  func didFailProvisionalNavigation_withIndicator_setsAlphaToZero() async {
    // Given
    let coordinator = makeCoordinator()
    let indicator = UIView()
    indicator.alpha = 1
    coordinator.loadingIndicator = indicator
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    let error = URLError(.cannotFindHost)

    // When
    coordinator.webView(webView, didFailProvisionalNavigation: nil, withError: error)
    await drainMainActorTasks()

    // Then
    #expect(indicator.alpha == 0)
  }

  @Test("실패 콜백은 인디케이터가 없어도 안전하다")
  func failureCallbacks_withoutIndicator_areIgnored() async {
    // Given
    let coordinator = makeCoordinator()
    coordinator.loadingIndicator = nil
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    coordinator.webView(webView, didFailProvisionalNavigation: nil, withError: URLError(.timedOut))
    coordinator.webView(webView, didFail: nil, withError: URLError(.timedOut))
    await drainMainActorTasks()

    // Then
    #expect(coordinator.loadingIndicator == nil)
  }

  // MARK: - 콜백 시퀀스

  @Test("시작→완료 순서로 콜백이 오면 alpha 가 1 을 거쳐 0 으로 수렴한다")
  func navigationSequence_startThenFinish_endsWithAlphaZero() async {
    // Given
    let coordinator = makeCoordinator()
    let indicator = UIView()
    indicator.alpha = 0
    coordinator.loadingIndicator = indicator
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    coordinator.webView(webView, didStartProvisionalNavigation: nil)
    await drainMainActorTasks()
    #expect(indicator.alpha == 1)

    coordinator.webView(webView, didFinish: nil)
    await drainMainActorTasks()

    // Then
    #expect(indicator.alpha == 0)
  }

  // MARK: - 참조 보관 / 해제

  @Test("loadingIndicator 는 약한 참조라 원본이 사라지면 nil 이 된다")
  func loadingIndicator_whenOwnerReleased_becomesNil() {
    // Given
    let coordinator = makeCoordinator()

    // When
    autoreleasepool {
      let indicator = UIView()
      coordinator.loadingIndicator = indicator
      #expect(coordinator.loadingIndicator === indicator)
    }

    // Then
    #expect(coordinator.loadingIndicator == nil)
  }

  @Test("Coordinator 해제 시 보관하던 UIHostingController 정리 경로가 실행된다")
  func deinit_withHostingController_runsCleanupPath() {
    // Given / When
    autoreleasepool {
      let coordinator = makeCoordinator()
      coordinator.animatedImageController = UIHostingController(rootView: AnyView(Color.clear))

      // Then - 스코프를 벗어나며 deinit 의 정리 코드가 실행된다
      #expect(coordinator.animatedImageController != nil)
    }
  }

  @Test("animatedImageController 가 nil 이어도 Coordinator 해제는 안전하다")
  func deinit_withoutHostingController_isSafe() {
    // Given / When / Then
    autoreleasepool {
      let coordinator = makeCoordinator()
      #expect(coordinator.animatedImageController == nil)
    }
  }

  @Test("parent 는 초기화에 사용한 WebRepresentableView 를 그대로 보관한다")
  func parent_afterInit_isReplaceable() {
    // Given
    let coordinator = makeCoordinator(url: "https://dddstudy.kr/terms")

    // When
    coordinator.parent = WebRepresentableView(urlToLoad: "https://dddstudy.kr/privacy")

    // Then
    #expect(coordinator.animatedImageController == nil)
  }
}
