//
//  CustomNavigationBackBar.swift
//  DDDDesignKit
//
//  Created by DDD on 3/22/25.
//

import SwiftUI

public struct CustomNavigationBackBar: View {
  var buttonAction: () -> Void = { }
  
  public init(
    buttonAction: @escaping () -> Void
  ) {
    self.buttonAction = buttonAction
  }
  
  public var body: some View {
    HStack {
      Image(asset: .arrowBackWhite)
        .resizable()
        .scaledToFit()
        .frame(width: 10, height: 20)
        .foregroundStyle(.staticWhite)
        .onTapGesture {
          buttonAction()
        }
      Spacer()
    }
    .padding(.horizontal, 24)
  }
}
