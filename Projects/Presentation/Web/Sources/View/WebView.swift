//
//  WebView.swift
//  Profile
//
//  Created by DDD on 1/4/26.
//

import SwiftUI
import DDDDesignKit
import ComposableArchitecture


public struct WebView: View {
  @Bindable var store: StoreOf<WebReducer>

  public init(
    store: StoreOf<WebReducer>,
  ) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)

      VStack {
        Spacer()
          .frame(height: 12)

        CustomNavigationBackBar {
          store.send(.backToRoot)
        }

        Spacer()
          .frame(height: 20)

        WebRepresentableView(urlToLoad: store.url)
          .edgesIgnoringSafeArea(.bottom)
      }
      .navigationBarBackButtonHidden(true)
    }
  }
}

