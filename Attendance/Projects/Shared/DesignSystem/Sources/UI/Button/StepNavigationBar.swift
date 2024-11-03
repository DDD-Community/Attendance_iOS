//
//  StepNavigationBar.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/3/24.
//

import SwiftUI

public struct StepNavigationBar: View {
  var activeStep: Int
  var buttonAction: () -> Void
  
  public init(
    activeStep: Int,
    buttonAction: @escaping () -> Void
  ) {
    self.activeStep = activeStep
    self.buttonAction = buttonAction
  }
  
  public var body: some View {
    HStack {
      Image(asset: .backButton)
        .resizable()
        .scaledToFit()
        .frame(width: 12, height: 20)
        .foregroundStyle(Color.gray400)
        .onTapGesture {
          buttonAction()
        }
      
      Spacer()
      
      HStack(alignment: .center, spacing: 2) {
        ForEach(1...3, id: \.self) { step in
          Rectangle()
            .foregroundColor(.clear)
            .frame(maxWidth: 78, minHeight: 3, maxHeight: 3)
            .background(step <= activeStep ? Color.grayWhite : Color.gray80)
            .clipShape(Capsule())
        }
      }
      
      Spacer()
    }
    .padding(.horizontal, 16)
  }
}
