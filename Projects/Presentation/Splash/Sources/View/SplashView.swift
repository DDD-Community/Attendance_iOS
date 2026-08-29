//
//  SplashView.swift
//  Presentation
//
//  Created by DDD on 10/29/24.
//

import SwiftUI

import DDDDesignKit
import DDDSharedUI

import ComposableArchitecture
import SDWebImageSwiftUI

@ViewAction(for: Splash.self)
public struct SplashView: View {
  @Bindable public var store: StoreOf<Splash>
  @State private var isAnimating = false // GIF 애니메이션 상태 관리

  public init(
    store: StoreOf<Splash>
  ) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        Spacer()
        
        AnimatedImage(name: "DDDLoding.gif", isAnimating: $isAnimating)
          .resizable()
          .scaledToFit()
          .frame(width: 200, height: 200)
        
        Spacer()
      }
    }
    .onAppear {
      isAnimating = true // 화면 표시시 애니메이션 시작
      send(.onAppear)
    }
    .onDisappear {
      isAnimating = false // 화면 종료시 애니메이션 중지 (메모리 절약)
    }
    .customAlert($store.scope(state: \.customAlert, action: \.scope.customAlert))
  }
}


