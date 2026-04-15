//
//  CustomConfirmationPopupView.swift
//  DesignSystem
//
//  Created by Wonji Suh on 1/4/26.
//

import SwiftUI

struct CustomConfirmationPopup: View {
  private let title: String
  private let message: String
  private let confirmTitle: String
  private let cancelTitle: String
  private let isDestructive: Bool
  private let style: CustomAlertStyle
  private let checkboxTitle: String
  private let onConfirm: () -> Void
  private let onCancel: () -> Void
  private let onPolicyTap: () -> Void
  @State private var isChecked = false
  @State private var isContentVisible = false

  init(
    title: String,
    message: String,
    confirmTitle: String,
    cancelTitle: String,
    isDestructive: Bool,
    style: CustomAlertStyle,
    checkboxTitle: String,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void,
    onPolicyTap: @escaping () -> Void
  ) {
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.isDestructive = isDestructive
    self.style = style
    self.checkboxTitle = checkboxTitle
    self.onConfirm = onConfirm
    self.onCancel = onCancel
    self.onPolicyTap = onPolicyTap
  }

  var body: some View {
    ZStack {
      Color.black
        .opacity(isContentVisible ? 0.6 : 0)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
          if style != .consent {
            onCancel()
          }
        }

      Group {
        if style == .consent {
          consentContent
        } else {
          confirmationContent
        }
      }
      .padding(.horizontal, 10)
      .offset(y: isContentVisible ? 0 : 120)
      .opacity(isContentVisible ? 1 : 0)
    }
    .onAppear {
      withAnimation(.appModal) {
        isContentVisible = true
      }
    }
  }

  private var confirmationContent: some View {
    VStack(alignment: .center, spacing: 24) {
      VStack(alignment: .center, spacing: 8) {
        Text(title)
          .pretendardCustomFont(textStyle: .title3NormalBold)
          .foregroundStyle(.staticWhite)
          .multilineTextAlignment(.center)

        if !message.isEmpty {
          Text(message)
            .pretendardCustomFont(textStyle: .body3NormalRegular)
            .foregroundStyle(.textSecondary)
            .multilineTextAlignment(.center)
        }
      }

      HStack(spacing: 12) {
        Button {
          onConfirm()
        } label: {
          Text(confirmTitle)
            .pretendardFont(family: .Medium, size: 16)
            .foregroundStyle(.staticWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .background(.gray80)
        .clipShape(.rect(cornerRadius: 20))
        .contentShape(.rect(cornerRadius: 20))

        Button {
          onCancel()
        } label: {
          Text(cancelTitle)
            .pretendardFont(family: .Medium, size: 16)
            .foregroundStyle(.staticWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .background(.blue40)
        .clipShape(.rect(cornerRadius: 20))
        .contentShape(.rect(cornerRadius: 20))
      }
    }
    .padding(.vertical, 32)
    .padding(.horizontal, 24)
    .frame(width: 320)
    .background(.gray90)
    .clipShape(.rect(cornerRadius: 20))
    .onTapGesture {}
  }

  private var consentContent: some View {
    VStack(alignment: .center, spacing: 16) {
      Text(title)
        .pretendardCustomFont(textStyle: .title3NormalBold)
        .foregroundStyle(.staticWhite)
        .multilineTextAlignment(.center)

      if !message.isEmpty {
        Text(message)
          .pretendardCustomFont(textStyle: .body3NormalRegular)
          .foregroundStyle(.textSecondary)
          .multilineTextAlignment(.center)
      }

      HStack(spacing: 8) {
        Button {
          isChecked.toggle()
          if isChecked {
            onConfirm()
          }
        } label: {
          RoundedRectangle(cornerRadius: 4)
            .stroke(.gray60, lineWidth: 1)
            .frame(width: 15, height: 15)
            .overlay {
              if isChecked {
                Image(systemName: "checkmark")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundStyle(.staticWhite)
              }
            }
            .padding(6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

        Text(checkboxTitle)
          .pretendardCustomFont(textStyle: .body3NormalRegular)
          .foregroundStyle(.staticWhite)
          .underline(true, color: .mediumGray)
          .onTapGesture {
            onPolicyTap()
          }
      }
      .padding(.top, 4)
    }
    .padding(.vertical, 24)
    .padding(.horizontal, 20)
    .frame(width: 300)
    .background(.gray90)
    .clipShape(.rect(cornerRadius: 20))
    .onTapGesture {}
  }

}

#Preview("Item Based") {
  VStack {
    Text("Background Content")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.gray.opacity(0.2))
  }
  .customConfirmationPopup(
    item: .withdrawAccount(
      onConfirm: {
        print("탈퇴하기 선택")
      },
      onCancel: {
        print("취소 선택")
      }
    )
  )
}

#Preview("Parameter Based") {
  VStack {
    Text("Background Content")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.gray.opacity(0.2))
  }
  .customConfirmationPopup(
    isPresented: true,
    title: "정말 탈퇴하시겠습니까?",
    message: "탈퇴 시, 등록된 모든 출석 데이터가 삭제됩니다.",
    confirmTitle: "탈퇴하기",
    cancelTitle: "취소",
    isDestructive: true,
    onConfirm: {
      print("탈퇴하기 선택")
    },
    onCancel: {
      print("취소 선택")
    }
  )
}
