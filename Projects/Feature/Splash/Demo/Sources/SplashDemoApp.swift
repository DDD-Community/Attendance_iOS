//
//  SplashDemoApp.swift
//  SplashDemo
//
//  Created by DDD on 2026-09-02
//
//  앱 전체를 빌드하지 않고 Splash 화면만 확인하기 위한 단독 실행 앱.
//

import ComposableArchitecture
import DDDDesignKit
import Splash
import SwiftUI

@main
struct SplashDemoApp: App {
  init() {
    // 앱과 동일하게 런타임에 폰트를 등록한다.
    PretendardFontFamily.registerFonts()
  }

  var body: some Scene {
    WindowGroup {
      SplashView(
        store: Store(initialState: Splash.State()) {
          Splash()
        }
      )
    }
  }
}
