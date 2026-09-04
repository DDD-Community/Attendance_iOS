//
//  CustomModal.swift
//  DDDDesignKit
//
//  Created by DDD on 2/7/25.
//

import SwiftUI

public extension View {
  /// Alert를 띄우는 Modifier
  ///
  /// - Parameters:
  ///   - isPresented: Alert 표시 여부
  ///   - title: 제목
  ///   - message: 메시지
  ///   - onConfirm: 확인 버튼 터치 시 액션
  func dddAlert(
    isPresented: Bool,
    title: String,
    message: String,
    onConfirm: @escaping () -> Void
  ) -> some View {
    self.modifier(
      CustomAlertModifier(
        isPresented: isPresented,
        title: title,
        message: message,
        onConfirm: onConfirm
      )
    )
  }
}

struct CustomAlertModifier: ViewModifier {
  private let isPresented: Bool
  private let title: String
  private let message: String
  private let onConfirm: () -> Void
  
  init(
    isPresented: Bool,
    title: String,
    message: String,
    onConfirm: @escaping () -> Void
  ) {
    self.isPresented = isPresented
    self.title = title
    self.message = message
    self.onConfirm = onConfirm
  }
  
  func body(content: Content) -> some View {
    content
      .overlay {
        if isPresented {
          CustomAlert(
            title: title,
            message: message,
            onConfirm: onConfirm
          )
        }
      }
  }
}

struct CustomAlert: View {
  private let title: String
  private let message: String
  private let onConfirm: () -> Void
  
  init(
    title: String,
    message: String,
    onConfirm: @escaping () -> Void
  ) {
    self.title = title
    self.message = message
    self.onConfirm = onConfirm
  }
  
  var body: some View {
    ZStack {
      Color.backGroundPrimary
        .opacity(0.68)
        .edgesIgnoringSafeArea(.all)
      
      VStack(alignment: .center, spacing: 24) {
        VStack(alignment: .center, spacing: 4) {
          Text(title)
            .pretendardFont(family: .Bold, size: 20)
            .foregroundStyle(.textPrimary)
          
          Text(message)
            .pretendardFont(family: .Regular, size: 14)
            .foregroundStyle(.textSecondary)
        }
        
        Button {
          onConfirm()
        } label: {
          Text("확인")
            .pretendardFont(family: .Medium, size: 14)
            .foregroundStyle(.staticWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
        }
        .background(.blue40)
        .clipShape(.rect(cornerRadius: 99))
        .contentShape(.rect(cornerRadius: 99))
      }
      .padding(.vertical, 36)
      .padding(.horizontal, 24)
      .frame(width: 288)
      .background(.backGroundPrimary)
      .clipShape(.rect(cornerRadius: 28))
    }
  }
}
