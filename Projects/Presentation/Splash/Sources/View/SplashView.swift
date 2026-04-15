//
//  SplashView.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import SwiftUI

import DesignSystem
import Shareds

import ComposableArchitecture
import SDWebImageSwiftUI

public struct SplashView: View {
  @Bindable var store: StoreOf<Splash>
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
      store.send(.view(.onAppear))
    }
    .onDisappear {
      isAnimating = false // 화면 종료시 애니메이션 중지 (메모리 절약)
    }
    .customAlert($store.scope(state: \.customAlert, action: \.scope.customAlert))
  }
}


