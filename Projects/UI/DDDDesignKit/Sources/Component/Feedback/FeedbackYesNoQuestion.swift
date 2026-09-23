//
//  FeedbackYesNoQuestion.swift
//  DDDDesignKit
//
//  Created by DDD on 6/10/26.
//

import SwiftUI

/// "질문 + 예/아니오" 단일 선택 문항 컴포넌트.
/// 피드백 5·6번처럼 구조가 같은 문항을 `question`/`answer`만 바꿔 재사용한다.
public struct FeedbackYesNoQuestion: View {
  private var question: String
  @Binding private var answer: YesNoAnswer?

  public init(
    question: String,
    answer: Binding<YesNoAnswer?>
  ) {
    self.question = question
    _answer = answer
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(question)
        .pretendardFont(family: .Bold, size: 16)
        .foregroundStyle(Color.staticWhite)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack(spacing: 12) {
        ForEach(YesNoAnswer.allCases) { option in
          optionButton(option)
        }
      }
      .frame(maxWidth: .infinity)
    }
  }

  private func optionButton(_ option: YesNoAnswer) -> some View {
    let isSelected = answer == option
    return Button {
      answer = option
    } label: {
      Text(option.title)
        .pretendardFont(family: isSelected ? .Bold : .Medium, size: 16)
        .foregroundStyle(isSelected ? Color.staticWhite : Color.borderInactive)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 48)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .background {
          RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.statusFocus : Color.clear)
            .overlay {
              RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.borderNormal, lineWidth: isSelected ? 0 : 1)
            }
        }
    }
    .frame(maxWidth: .infinity)
    .contentShape(RoundedRectangle(cornerRadius: 12))
    .buttonStyle(.plain)
  }
}

#Preview {
  struct PreviewContainer: View {
    @State private var q5: YesNoAnswer? = .yes
    @State private var q6: YesNoAnswer? = .no

    var body: some View {
      VStack(spacing: 28) {
        FeedbackYesNoQuestion(
          question: "5. 인스타 인터뷰 카드뉴스에 인터뷰이로 참여할 의향이 있으신가요?",
          answer: $q5
        )
        FeedbackYesNoQuestion(
          question: "6. 다음 기수 운영진에 관심이 있으신가요?",
          answer: $q6
        )
      }
      .padding(24)
      .frame(maxWidth: 375)
      .background(Color.backGroundPrimary)
    }
  }
  return PreviewContainer()
}

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension FeedbackYesNoQuestion {
  /// `question` 을 바꾼 사본을 돌려준다.
  func question(_ question: String) -> Self {
    var copy = self
    copy.question = question
    return copy
  }
}
