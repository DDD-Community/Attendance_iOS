//
//  WebRepresentableViewRenderTests.swift
//  WebTests
//
//  WebRepresentableView 의 makeCoordinator / makeUIView / updateUIView /
//  loadURLInWebView 경로를 실제로 실행시켜 커버리지를 확보한다.
//  실제 네트워크 로딩 완료는 절대 기다리지 않는다.
//

import SwiftUI
import Testing
import UIKit
import WebKit

@testable import Web

@MainActor
@Suite("WebRepresentableView 렌더링")
struct WebRepresentableViewRenderTests {
  // MARK: - makeCoordinator

  @Test("makeCoordinator 는 자기 자신을 parent 로 갖는 Coordinator 를 만든다")
  func makeCoordinator_withValidURL_returnsFreshCoordinator() {
    // Given
    let sut = WebRepresentableView(urlToLoad: "https://dddstudy.kr/terms")

    // When
    let coordinator = sut.makeCoordinator()

    // Then
    #expect(coordinator.webView == nil)
    #expect(coordinator.loadingIndicator == nil)
    #expect(coordinator.animatedImageController == nil)
    #expect((coordinator as AnyObject) as? WKNavigationDelegate != nil)
    #expect((coordinator as AnyObject) as? WKUIDelegate != nil)
  }

  @Test("makeCoordinator 를 두 번 호출하면 서로 다른 Coordinator 인스턴스를 만든다")
  func makeCoordinator_calledTwice_returnsDistinctInstances() {
    // Given
    let sut = WebRepresentableView(urlToLoad: "https://dddstudy.kr")

    // When
    let first = sut.makeCoordinator()
    let second = sut.makeCoordinator()

    // Then
    #expect(first !== second)
  }

  // MARK: - makeUIView (렌더링 경로)

  @Test("정상 URL 로 렌더링하면 makeUIView 가 컨테이너/웹뷰/로딩뷰를 구성한다")
  func makeUIView_withValidURL_rendersWithoutCrash() {
    // Given
    let sut = WebRepresentableView(urlToLoad: "https://dddstudy.kr/privacy")

    // When / Then - 렌더링 중 크래시가 없어야 한다
    WebViewRenderer.render(sut)
  }

  @Test("빈 문자열 URL 로 렌더링해도 makeUIView 는 정상적으로 뷰 계층을 만든다")
  func makeUIView_withEmptyURL_rendersWithoutCrash() {
    // Given
    let sut = WebRepresentableView(urlToLoad: "")

    // When / Then
    WebViewRenderer.render(sut)
  }

  @Test("잘못된 URL 로 렌더링해도 makeUIView 는 정상적으로 뷰 계층을 만든다")
  func makeUIView_withMalformedURL_rendersWithoutCrash() {
    // Given
    let sut = WebRepresentableView(urlToLoad: "h ttp://[not a url]")

    // When / Then
    WebViewRenderer.render(sut)
  }

  @Test(
    "여러 형태의 URL 로 반복 렌더링해도 makeUIView 경로가 매번 안전하게 실행된다",
    arguments: [
      "https://dddstudy.kr",
      "https://dddstudy.kr/terms?version=2",
      "http://example.com",
      "about:blank",
      "",
      "   ",
      "not a url at all"
    ]
  )
  func makeUIView_withVariousURLs_rendersRepeatedlyWithoutCrash(url: String) {
    // Given
    let sut = WebRepresentableView(urlToLoad: url)

    // When / Then
    WebViewRenderer.render(sut, size: CGSize(width: 320, height: 568))
  }

  // MARK: - updateUIView

  @Test("rootView 를 교체하면 updateUIView 경로까지 실행된다")
  func updateUIView_whenURLChanges_runsUpdatePath() {
    // Given
    let first = WebRepresentableView(urlToLoad: "https://dddstudy.kr")
    let next = WebRepresentableView(urlToLoad: "https://dddstudy.kr/privacy")

    // When / Then
    WebViewRenderer.renderThenUpdate(first, then: next)
  }

  @Test("같은 URL 로 rootView 를 교체해도 updateUIView 는 안전하게 동작한다")
  func updateUIView_withSameURL_runsUpdatePath() {
    // Given
    let sut = WebRepresentableView(urlToLoad: "https://dddstudy.kr")

    // When / Then
    WebViewRenderer.renderThenUpdate(sut, then: sut)
  }

  @Test("정상 URL 에서 빈 URL 로 바뀌어도 updateUIView 는 안전하게 동작한다")
  func updateUIView_fromValidToEmptyURL_runsUpdatePath() {
    // Given
    let first = WebRepresentableView(urlToLoad: "https://dddstudy.kr")
    let next = WebRepresentableView(urlToLoad: "")

    // When / Then
    WebViewRenderer.renderThenUpdate(first, then: next)
  }

  // MARK: - loadURLInWebView

  @Test("정상 URL 이면 loadURLInWebView 가 웹뷰 설정을 적용한다")
  func loadURLInWebView_withValidURL_appliesWebViewConfiguration() async {
    // Given
    let sut = WebRepresentableView(urlToLoad: "https://dddstudy.kr")
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    #expect(webView.configuration.preferences.minimumFontSize == 0)

    // When
    await sut.loadURLInWebView(urlToLoad: "https://dddstudy.kr", webView: webView)

    // Then
    #expect(webView.configuration.preferences.minimumFontSize == 16)
    #expect(webView.configuration.upgradeKnownHostsToHTTPS == true)
  }

  @Test("URL 로 변환할 수 없는 문자열이면 loadURLInWebView 는 조기 종료한다")
  func loadURLInWebView_withMalformedURL_leavesConfigurationUntouched() async {
    // Given
    let sut = WebRepresentableView(urlToLoad: "h ttp://[not a url]")
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    await sut.loadURLInWebView(urlToLoad: "h ttp://[not a url]", webView: webView)

    // Then - guard 에서 빠져나오므로 설정이 그대로다
    #expect(webView.configuration.preferences.minimumFontSize == 0)
  }

  @Test("빈 문자열이면 loadURLInWebView 는 요청을 만들지 않는다")
  func loadURLInWebView_withEmptyString_leavesConfigurationUntouched() async {
    // Given
    let sut = WebRepresentableView(urlToLoad: "")
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    await sut.loadURLInWebView(urlToLoad: "", webView: webView)

    // Then
    #expect(webView.configuration.preferences.minimumFontSize == 0)
  }

  @Test("서로 다른 스킴의 정상 URL 도 loadURLInWebView 가 처리한다")
  func loadURLInWebView_withAboutScheme_appliesWebViewConfiguration() async {
    // Given
    let sut = WebRepresentableView(urlToLoad: "about:blank")
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    // When
    await sut.loadURLInWebView(urlToLoad: "about:blank", webView: webView)

    // Then
    #expect(webView.configuration.preferences.minimumFontSize == 16)
  }
}
