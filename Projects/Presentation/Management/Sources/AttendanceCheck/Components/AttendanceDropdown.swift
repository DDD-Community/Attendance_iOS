//
//  AttendanceDropdown.swift
//  DesignSystem
//
//  Created by Wonji Suh on 1/13/26.
//

import SwiftUI
import Entity
import DesignSystem

struct AttendanceDropdown: View {
  @State private var isExpanded = false
  @State private var selectedStatus: AttendanceStatus

  private let availableStatuses: [AttendanceStatus]
  private let onSelectionChanged: (AttendanceStatus) -> Void // AttendanceStatus 반환

  init(
    selectedStatus: AttendanceStatus,
    availableStatuses: [AttendanceStatus],
    onSelectionChanged: @escaping (AttendanceStatus) -> Void // AttendanceStatus 반환
  ) {
    self._selectedStatus = State(initialValue: selectedStatus)
    self.availableStatuses = availableStatuses
    self.onSelectionChanged = onSelectionChanged
  }

  var body: some View {
    // 드롭다운 헤더 (고정 높이)
    Button {
      withAnimation(.easeInOut(duration: 0.2)) {
        isExpanded.toggle()
      }
    } label: {
      HStack {
        Text(selectedStatus.desc)
          .pretendardCustomFont(textStyle: .body2NormalMedium)
          .foregroundStyle(.staticWhite)

        Spacer()

        Image(systemName: "chevron.down")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.gray60)
          .rotationEffect(.degrees(isExpanded ? 180 : 0))
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(height: 58)
      .background(.gray80)
      .clipShape(.rect(cornerRadius: 20))
      .overlay {
        RoundedRectangle(cornerRadius: 20)
          .stroke(.gray80, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
    .overlay(
      // 드롭다운 옵션들을 오버레이로 완전히 분리
      Group {
        if isExpanded {
          VStack(spacing: 0) {
            ForEach(availableStatuses, id: \.rawValue) { status in
              Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                  selectedStatus = status
                  isExpanded = false
                  onSelectionChanged(status) // AttendanceStatus 직접 반환
                }
              } label: {
                HStack {
                  Text(status.desc)
                    .pretendardCustomFont(textStyle: .body2NormalMedium)
                    .foregroundStyle(status == selectedStatus ? .blue40 : .staticWhite)

                  Spacer()

                  if status == selectedStatus {
                    Image(systemName: "checkmark")
                      .font(.system(size: 14, weight: .medium))
                      .foregroundStyle(.blue40)
                  }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(height: 44)
                .background(.gray80)
              }
              .buttonStyle(.plain)

              if status != availableStatuses.last {
                Rectangle()
                  .fill(.gray70)
                  .frame(height: 1)
                  .padding(.horizontal, 16)
              }
            }
          }
          .background(.gray80)
          .clipShape(.rect(cornerRadius: 8))
          .overlay {
            RoundedRectangle(cornerRadius: 8)
              .stroke(.gray70, lineWidth: 1)
          }
          .offset(y: 64) // 헤더(58) + 간격(6)
          .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
        }
      },
      alignment: .topLeading
    )
    .zIndex(isExpanded ? 9999 : 1) // 전체 컴포넌트의 zIndex 조정
  }
}

#Preview {
  VStack {
    AttendanceDropdown(
      selectedStatus: .attended,
      availableStatuses: AttendanceStatus.allCases
    ) { newStatus in
      print("Selected: \(newStatus)")
    }

    Spacer()
  }
  .padding()
  .background(.gray90)
}
