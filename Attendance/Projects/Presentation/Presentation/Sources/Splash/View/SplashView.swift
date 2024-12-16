//
//  SplashView.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation
import SwiftUI

import DesignSystem

import ComposableArchitecture
import SDWebImageSwiftUI

public struct SplashView: View {
  @Bindable var store: StoreOf<Splash>
  
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
        
        AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
          .resizable()
          .scaledToFit()
          .frame(width: 200, height: 200)
        
        
        Spacer()
      }
    }
    .onAppear {
      store.send(.async(.fetchUser))
    }
  }
}
