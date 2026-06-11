//
//  NonParticipantsModalView.swift
//  Management
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

import DesignSystem
import Entity

/// 투표 미참여 멤버 명단 모달 (Figma: iOS/운영진_미참여명단_모달)
struct NonParticipantsModalView: View {
  let members: [NonParticipant]
  let onClose: () -> Void

  @State private var isContentVisible = false

  var body: some View {
    ZStack {
      Color.black
        .opacity(isContentVisible ? 0.6 : 0)
        .ignoresSafeArea()
        .onTapGesture { dismiss() }

      card
        .offset(y: isContentVisible ? 0 : 120)
        .opacity(isContentVisible ? 1 : 0)
    }
    .onAppear {
      withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
        isContentVisible = true
      }
    }
  }

  private var card: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("투표 미참여 멤버")
        .pretendardFont(family: .Bold, size: 20)
        .foregroundStyle(.staticWhite)

      Text("총 \(members.count)명이 아직 투표하지 않았어요.")
        .pretendardFont(family: .Medium, size: 14)
        .foregroundStyle(.textCaption)

      memberList

      Spacer().frame(height: 8)

      Button {
        dismiss()
      } label: {
        Text("닫기")
          .pretendardFont(family: .Bold, size: 15)
          .foregroundStyle(.staticWhite)
          .frame(maxWidth: .infinity)
          .frame(height: 48)
          .background {
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.blue40)
          }
      }
      .buttonStyle(.plain)
    }
    .padding(.top, 24)
    .padding(.bottom, 16)
    .padding(.horizontal, 20)
    .background {
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray90)
    }
    .padding(.horizontal, 24)
  }

  private var memberList: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
          memberRow(member)

          if index < members.count - 1 {
            Rectangle()
              .fill(Color.gray80)
              .frame(height: 1)
          }
        }
      }
    }
    .frame(maxHeight: 360)
    .scrollBounceBehavior(.basedOnSize)
  }

  private func memberRow(_ member: NonParticipant) -> some View {
    HStack(spacing: 8) {
      Text(member.name)
        .pretendardFont(family: .Bold, size: 15)
        .foregroundStyle(.staticWhite)

      teamChip(member.teamName)

      Spacer(minLength: 0)

      if let attendance = member.attendance {
        attendanceChip(attendance)
      }
    }
    .padding(.vertical, 12)
  }

  private func teamChip(_ title: String) -> some View {
    Text(title)
      .pretendardFont(family: .Medium, size: 12)
      .foregroundStyle(.borderInactive)
      .padding(.horizontal, 8)
      .padding(.vertical, 3)
      .background {
        RoundedRectangle(cornerRadius: 6)
          .fill(Color.gray80)
      }
  }

  private func attendanceChip(_ mark: VoteAttendanceMark) -> some View {
    Text(mark.title)
      .pretendardFont(family: .Medium, size: 12)
      .foregroundStyle(attendanceTextColor(mark))
      .padding(.horizontal, 8)
      .padding(.vertical, 3)
      .background {
        RoundedRectangle(cornerRadius: 6)
          .fill(attendanceBackgroundColor(mark))
      }
  }

  private func attendanceTextColor(_ mark: VoteAttendanceMark) -> Color {
    switch mark {
    case .attended: return .attendanceAttendedText
    case .late: return .attendanceLateText
    case .absent: return .attendanceAbsentText
    }
  }

  private func attendanceBackgroundColor(_ mark: VoteAttendanceMark) -> Color {
    switch mark {
    case .attended: return .attendanceAttendedBg
    case .late: return .attendanceLateBg
    case .absent: return .attendanceAbsentBg
    }
  }

  private func dismiss() {
    withAnimation(.easeInOut(duration: 0.2)) {
      isContentVisible = false
    }
    onClose()
  }
}
