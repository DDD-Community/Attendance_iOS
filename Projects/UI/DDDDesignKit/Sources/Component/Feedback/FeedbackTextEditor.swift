//
//  FeedbackTextEditor.swift
//  DDDDesignKit
//
//  Created by DDD on 6/10/26.
//

import SwiftUI

/// 제목 + (설명) + 입력창 + 글자수 카운터로 구성된 재사용 입력 컴포넌트.
/// "좋았던 이유", "2-1. 어떤 부분이 아쉬웠나요?", "3. 운영진에게 더 바라는 점" 등
/// 구조가 같은 자유 입력 문항을 이 하나로 처리한다.
public struct FeedbackTextEditor: View {
  /// 제목 글자 스타일. 메인 문항은 `primary`, 하위 문항(1-1, 2-1)은 `secondary`.
  public enum TitleStyle {
    case primary // #FFFFFF, Bold, 16
    case secondary // #EAEAEA, Medium, 15
  }

  private let title: String?
  private let titleStyle: TitleStyle
  private let description: String?
  private let placeholder: String
  @Binding private var text: String
  private let minLength: Int
  private let maxLength: Int
  private let height: CGFloat

  /// 입력된 텍스트가 입력창 안에 다 들어가는 동안에는 내부 스크롤을 끈다.
  /// 짧은 글에서 첫 글자를 입력할 때 텍스트가 위로 튀어 잘리는 현상을 막고,
  /// 150px를 넘어 내용이 넘칠 때만 내부 스크롤을 다시 켜기 위한 측정값.
  @State private var contentHeight: CGFloat = 0

  public init(
    title: String? = nil,
    titleStyle: TitleStyle = .primary,
    description: String? = nil,
    placeholder: String,
    text: Binding<String>,
    minLength: Int = 0,
    maxLength: Int = 300,
    height: CGFloat = 150
  ) {
    self.title = title
    self.titleStyle = titleStyle
    self.description = description
    self.placeholder = placeholder
    _text = text
    self.minLength = minLength
    self.maxLength = maxLength
    self.height = height
  }

  private var isOverLimit: Bool { text.count > maxLength }
  private var contentLength: Int { text.normalizedInputCharacterCount }
  /// 비어 있을 때(미입력)는 에러로 보지 않고, 입력이 시작된 뒤 최소 글자수 미만일 때만 강조.
  private var isUnderMin: Bool { minLength > 0 && !text.isEmpty && contentLength < minLength }
  private var isError: Bool { isOverLimit || isUnderMin }
  /// 텍스트가 입력창 높이를 넘쳐야만 내부 스크롤 허용(첫 입력 점프 방지).
  private var needsScroll: Bool { contentHeight > height - 24 }

  public var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let title {
        titleView(title)
      }

      if let description {
        Text(description)
          .pretendardFont(family: .Medium, size: 14)
          .foregroundStyle(Color.textCaption)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      editorBox
      counterRow
    }
  }

  @ViewBuilder
  private func titleView(_ title: String) -> some View {
    switch titleStyle {
    case .primary:
      Text(title)
        .pretendardFont(family: .Bold, size: 16)
        .foregroundStyle(Color.staticWhite)
        .frame(maxWidth: .infinity, alignment: .leading)
    case .secondary:
      Text(title)
        .pretendardFont(family: .Medium, size: 15)
        .foregroundStyle(Color.textSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var editorBox: some View {
    ZStack(alignment: .topLeading) {
      if text.isEmpty {
        Text(placeholder)
          .pretendardFont(family: .Medium, size: 14)
          .foregroundStyle(Color.gray60)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .padding(.vertical, 14)
      }

      TextEditor(text: $text)
        .pretendardFont(family: .Medium, size: 14)
        .foregroundStyle(Color.staticWhite)
        .tint(Color.statusFocus)
        .scrollContentBackground(.hidden)
        .scrollDisabled(!needsScroll)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
    }
    .frame(height: height, alignment: .topLeading)
    .background {
      RoundedRectangle(cornerRadius: 12)
        .strokeBorder(
          isError ? Color.statusErrorText : Color.borderDisabled,
          lineWidth: 1
        )
    }
    .background(alignment: .topLeading) {
      // 보이지 않는 미러 텍스트로 실제 콘텐츠 높이를 측정해 스크롤 필요 여부를 판단.
      Text(text.isEmpty ? " " : text)
        .pretendardFont(family: .Medium, size: 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background {
          GeometryReader { proxy in
            Color.clear.preference(key: ContentHeightKey.self, value: proxy.size.height)
          }
        }
        .hidden()
    }
    .onPreferenceChange(ContentHeightKey.self) { contentHeight = $0 }
    .onChange(of: text) { _, newValue in
      guard newValue.count > maxLength else { return }
      text = String(newValue.prefix(maxLength))
      ToastManager.shared.showWarning("최대 \(maxLength)자까지 입력할 수 있어요")
    }
  }

  private var counterRow: some View {
    HStack(spacing: 8) {
      if let hint = errorHint {
        Text(hint)
          .pretendardFont(family: .Medium, size: 13)
          .foregroundStyle(Color.statusErrorText)
          .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        Spacer(minLength: 0)
      }

      Text("\(text.count) / \(maxLength)")
        .pretendardFont(family: .Medium, size: 13)
        .foregroundStyle(isError ? Color.statusErrorText : Color.gray60)
    }
    .padding(.top, 6)
  }

  /// 좌하단에 노출할 안내 문구. 초과가 최소 글자수 미만보다 우선.
  private var errorHint: String? {
    if isOverLimit { return "최대 \(maxLength)자까지 입력할 수 있어요." }
    if isUnderMin { return "최소 \(minLength)자 이상 입력해주세요." }
    return nil
  }
}

private struct ContentHeightKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }
}

private extension String {
  var normalizedInputCharacterCount: Int {
    split(whereSeparator: \.isWhitespace)
      .joined(separator: " ")
      .count
  }
}

#Preview {
  struct PreviewContainer: View {
    @State private var reason = ""
    @State private var improve = ""

    var body: some View {
      VStack(spacing: 28) {
        FeedbackTextEditor(
          title: "좋았던 이유를 작성해주세요.",
          placeholder: "해당 팀을 선택하신 이유를 적어주세요. 실현 가능성, 사용자 편의성, 독창성 등을 종합적으로 고려하여 작성해 주세요.",
          text: $reason,
          minLength: 5
        )

        FeedbackTextEditor(
          title: "3. 운영진에게 더 바라는 점",
          description: "ex) 지원 방식, 일정 관리, 진행 흐름, 커뮤니케이션 등",
          placeholder: "자유롭게 의견을 남겨주세요.",
          text: $improve
        )
      }
      .padding(24)
      .frame(maxWidth: 375)
      .background(Color.backGroundPrimary)
    }
  }
  return PreviewContainer()
}
