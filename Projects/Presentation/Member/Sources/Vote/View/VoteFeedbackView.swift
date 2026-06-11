//
//  VoteFeedbackView.swift
//  Member
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

import DesignSystem
import Entity

/// [멤버] 투표 2단계 — 참여 경험 피드백 화면 (Figma: iOS/투표_2단계(피드백))
struct VoteFeedbackView: View {
  private struct QuestionAnswer: Identifiable {
    let question: FeedbackQuestion
    var selectedOptionIds: Set<String> = []
    var textValue: String = ""
    var boolAnswer: YesNoAnswer?
    var followUpTexts: [String: String] = [:]
    var id: String { question.id }
  }

  private let info: FeedbackTemplateInfo
  private let onSubmit: ([FeedbackAnswer]) -> Void

  @State private var answers: [QuestionAnswer]

  init(
    info: FeedbackTemplateInfo,
    onSubmit: @escaping ([FeedbackAnswer]) -> Void = { _ in }
  ) {
    self.info = info
    self.onSubmit = onSubmit
    _answers = State(initialValue: info.template.questions.map { QuestionAnswer(question: $0) })
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        StepProgressBar(currentStep: 2, totalSteps: 2)

        headerView

        ForEach(answers.indices, id: \.self) { index in
          FeedbackQuestionView(
            index: index,
            question: answers[index].question,
            selectedOptionIds: $answers[index].selectedOptionIds,
            textValue: $answers[index].textValue,
            boolAnswer: $answers[index].boolAnswer,
            followUpTexts: $answers[index].followUpTexts
          )
        }

        submitButton
      }
      .padding(.horizontal, 24)
      .padding(.top, 8)
      .padding(.bottom, 40)
    }
    .scrollIndicators(.hidden)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backGroundPrimary)
  }

  private var headerView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(info.template.title)
        .pretendardFont(family: .Bold, size: 20)
        .foregroundStyle(.staticWhite)

      Text(info.template.description)
        .pretendardFont(family: .Medium, size: 14)
        .foregroundStyle(.textCaption)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func makeFeedbackAnswers() -> [FeedbackAnswer] {
    var result: [FeedbackAnswer] = []
    for answer in answers {
      switch answer.question.type {
      case .multiSelect, .teamSelect:
        result.append(FeedbackAnswer(
          questionId: answer.question.id,
          optionIds: Array(answer.selectedOptionIds),
          textValue: nil,
          boolValue: nil
        ))

      case .longText:
        result.append(FeedbackAnswer(
          questionId: answer.question.id,
          optionIds: nil,
          textValue: answer.textValue.isEmpty ? nil : answer.textValue,
          boolValue: nil
        ))

      case .boolean:
        result.append(FeedbackAnswer(
          questionId: answer.question.id,
          optionIds: nil,
          textValue: nil,
          boolValue: answer.boolAnswer.map { $0 == .yes }
        ))
      }

      // followUp 텍스트 답변은 별도 질문으로 함께 제출한다.
      for (followUpId, text) in answer.followUpTexts where !text.isEmpty {
        result.append(FeedbackAnswer(
          questionId: followUpId,
          optionIds: nil,
          textValue: text,
          boolValue: nil
        ))
      }
    }
    return result
  }

  private var submitButton: some View {
    Button {
      onSubmit(makeFeedbackAnswers())
    } label: {
      Text("제출하기")
        .pretendardFont(family: .Bold, size: 16)
        .foregroundStyle(.staticWhite)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background {
          RoundedRectangle(cornerRadius: 14)
            .fill(Color.blue40)
        }
    }
    .buttonStyle(.plain)
  }
}
