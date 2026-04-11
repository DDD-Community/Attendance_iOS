//
//  LoadingView.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 5/9/25.
//

import SwiftUI

import SwiftUIX
import SDWebImageSwiftUI

public struct LoadingView: View {
  @State private var isVisible = false

  public init() {}

  public var body: some View {
    LazyView {
      ZStack {
        Color.basicBlack
          .edgesIgnoringSafeArea(.all)

        VStack {
          loadingView()
        }
      }
      .onAppear {
        isVisible = true
      }
      .onDisappear {
        isVisible = false
      }
    }
  }
}

extension LoadingView {
  @ViewBuilder
  fileprivate func loadingView() -> some View {
    VStack {
      Spacer()
      
      AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(isVisible))
        .resizable()
        .scaledToFit()
        .frame(width: 200, height: 200)
      
      Spacer()
    }
  }
}

