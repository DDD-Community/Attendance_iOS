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
    }
  }
}

extension LoadingView {
  @ViewBuilder
  fileprivate func loadingView() -> some View {
    VStack {
      Spacer()
      
      AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
        .resizable()
        .scaledToFit()
        .frame(width: 200, height: 200)
      
      Spacer()
    }
  }
}

