//
//  StepNavigationBar.swift
//  DDDDesignKit
//
//  Created by DDD on 11/3/24.
//

import SwiftUI

public struct StepNavigationBar: View {
  private var activeStep: Int
  private var buttonAction: () -> Void
  
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

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension StepNavigationBar {
  /// `activeStep` 을 바꾼 사본을 돌려준다.
  func activeStep(_ activeStep: Int) -> Self {
    var copy = self
    copy.activeStep = activeStep
    return copy
  }
  /// `buttonAction` 을 바꾼 사본을 돌려준다.
  func buttonAction(_ buttonAction: @escaping () -> Void) -> Self {
    var copy = self
    copy.buttonAction = buttonAction
    return copy
  }
}
