//
//  CustomNavigationBar.swift
//  DDDAttendance
//
//  Created by DDD on 6/22/24.
//

import SwiftUI

public struct CustomNavigationBar: View {
  private var backAction: () -> Void
  private var addAction: () -> Void
  private var image: ImageAsset
  
  public init(
    backAction: @escaping () -> Void,
    addAction: @escaping () -> Void,
    image: ImageAsset
  ) {
    self.backAction = backAction
    self.addAction = addAction
    self.image = image
  }
  
  public var body: some View {
    HStack {
      Image(asset: .arrowBackWhite)
        .resizable()
        .scaledToFit()
        .frame(width: 12, height: 20)
        .onTapGesture {
          backAction()
        }
      
      Spacer()
      
      HStack {
        Image(asset: image)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
          .foregroundStyle(Color.gray400)
          .onTapGesture {
            addAction()
          }
      }
      
    }
    .padding(.horizontal, 16)
  }
}

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension CustomNavigationBar {
  /// `backAction` 을 바꾼 사본을 돌려준다.
  func backAction(_ backAction: @escaping () -> Void) -> Self {
    var copy = self
    copy.backAction = backAction
    return copy
  }
  /// `addAction` 을 바꾼 사본을 돌려준다.
  func addAction(_ addAction: @escaping () -> Void) -> Self {
    var copy = self
    copy.addAction = addAction
    return copy
  }
  /// `image` 을 바꾼 사본을 돌려준다.
  func image(_ image: ImageAsset) -> Self {
    var copy = self
    copy.image = image
    return copy
  }
}
