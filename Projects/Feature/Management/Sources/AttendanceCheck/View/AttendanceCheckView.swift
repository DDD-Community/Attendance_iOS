//
//  AttendanceCheckView.swift
//  Presentation
//
//  Created by DDD on 1/16/25.
//

import AttendanceDomainInterface
import DDDCoreUI
import SwiftUI

import DDDDesignKit
import DDDSharedUI
import FeatureSharedUI
import OnBoardingDomainInterface

import ComposableArchitecture

@ViewAction(for: AttendanceCheck.self)
struct AttendanceCheckView: View {
  @Bindable var store: StoreOf<AttendanceCheck>
  @Namespace private var teamTabNamespace

  var body: some View {
    VStack {
      selectAttendanceDate()

      attendanceStatusView()

      selectPartType()

      selectPartAttendanceStatus()
    }
    .onAppear {
      send(.onAppear)
    }
    .sheet(item: $store.scope(
      state: \.destination?.scheduleModal,
      action: \.destination.scheduleModal
    )) { scheduleModalStore in
      ScheduleModalView(store: scheduleModalStore)
        .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.visible)
    }
    .alert($store.scope(state: \.alert, action: \.scope.alert))
    .attendanceModal($store.scope(state: \.attendanceModal, action: \.scope.attendanceModal))
  }
}

private extension AttendanceCheckView {
  @ViewBuilder
  func selectAttendanceDate() -> some View {
    VStack {                          // LazyVStack → VStack
      Spacer().frame(height: 24)
      
      HStack {
        Image(asset: .calender)
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 26)
        
        Spacer().frame(width: 4)
        
        Text(store.selectAttendanceDate.formatted(.yearMonthDayDotted))
          .dddFont(.body1NormalMedium)
          .foregroundStyle(.staticWhite)
        
        Spacer()
      }
      .contentShape(Rectangle())      // 탭 영역 확보(빈 곳도 탭되게)
      .onTapGesture {
        send(.tapSelectDate)
      }
    }
    .padding(.horizontal, 24)
  }

  @ViewBuilder
  func attendanceStatusView() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 14)

      DDDSharedUI.AttendanceCard(
        attendanceCount: store.attendanceCount,
        lateCount: store.lateCount,
        absentCount: store.absentCount,
        showWarning: false
      )
    }
    .padding(.horizontal, 24)
  }

  @ViewBuilder
  func selectPartType() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 28)

      ScrollViewReader { proxy in
        teamTabScroller(proxy: proxy)
      }
    }
    .simultaneousGesture(
      DragGesture(minimumDistance: 20)
        .onEnded { value in
          let swipeThreshold: CGFloat = 50
          withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if value.translation.width > swipeThreshold {
              _ = send(.swipeNext)
            } else if value.translation.width < -swipeThreshold {
              _ = send(.swipePrevious)
            }
          }
        }
    )
  }

  @ViewBuilder
  func teamTabScroller(proxy: ScrollViewProxy) -> some View {
    VStack {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(store.attendanceTeam) { item in
            teamTabItem(item: item)
          }
        }
        .padding(.horizontal, 24)
      }
      .scrollDisabled(true)

      Spacer()
        .frame(height: 12)

      Divider()
        .frame(height: 1)
        .background(.borderInactive.opacity(0.12))
        .offset(y: -12)
    }
    .onChange(of: store.selectPart) { _, newValue in
      guard let newValue,
            let target = store.attendanceTeam.first(where: { $0.teams == newValue })
      else { return }
      withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        proxy.scrollTo(target.id, anchor: .center)
      }
    }
  }

  @ViewBuilder
  func teamTabItem(item: SelectTeamEntity) -> some View {
    let mappedTeam = item.teams
    let isSelected = store.selectPart == mappedTeam

    VStack(spacing: .zero) {
      HStack {
        Spacer().frame(width: 16)

        Text(item.teams.attendanceListDescription)
          .pretendardFont(family: .Bold, size: 16)
          .foregroundColor(isSelected ? .staticWhite : .gray600)
          .animation(.easeInOut(duration: 0.25), value: store.selectPart)
          .background(teamTabWidthProbe(itemID: item.id))

        Spacer().frame(width: 16)
      }

      Spacer().frame(height: 12)

      teamTabUnderline(itemID: item.id, isSelected: isSelected)
    }
    .onPreferenceChange(TeamTextWidthPreferenceKey.self) { newWidths in
      send(.updateDividerWidths(newWidths))
    }
    .onTapGesture {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        _ = send(.selectPartButton(selectPart: item))
      }
    }
    .id(item.id)
  }

  @ViewBuilder
  func teamTabWidthProbe(itemID: Int) -> some View {
    GeometryReader { geometry in
      Color.clear
        .preference(key: TeamTextWidthPreferenceKey.self, value: [itemID: geometry.size.width])
    }
  }

  @ViewBuilder
  func teamTabUnderline(itemID: Int, isSelected: Bool) -> some View {
    ZStack {
      if isSelected {
        Rectangle()
          .fill(Color.blue40)
          .frame(width: store.dividerWidths[itemID] ?? 0, height: 2)
          .matchedGeometryEffect(id: "teamTabUnderline", in: teamTabNamespace)
      } else {
        Color.clear.frame(height: 2)
      }
    }
  }

  @ViewBuilder
  func selectPartAttendanceStatus() -> some View {
    if let selectPart = store.selectPart,
       [.web1, .web2, .and1, .and2, .ios1, .ios2].contains(selectPart)
    {
      selectPartAttendanceStatusCard()
        .simultaneousGesture(
          DragGesture(minimumDistance: 20)
            .onEnded { value in
              let swipeThreshold: CGFloat = 50
              withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if value.translation.width > swipeThreshold {
                  _ = send(.swipePrevious)
                } else if value.translation.width < -swipeThreshold {
                  _ = send(.swipeNext)
                }
              }
            }
        )

      Spacer()
        .frame(height: 20)
    } else {
      selectPartAttendanceStatusCard()
        .simultaneousGesture(
          DragGesture(minimumDistance: 20)
            .onEnded { value in
              let swipeThreshold: CGFloat = 50
              withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if value.translation.width > swipeThreshold {
                  _ = send(.swipePrevious)
                } else if value.translation.width < -swipeThreshold {
                  _ = send(.swipeNext)
                }
              }
            }
        )
    }
  }

  @ViewBuilder
  func selectPartAttendanceStatusCard() -> some View {
    let attendanceModel = getAttendanceModel()

    Group {
      if attendanceModel.isEmpty {
        noMemberAttendanceView()
      } else {
        AttendanceScrollView(attendanceModel: attendanceModel)
      }
    }
    .id(store.selectPart)
    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
  }

  private func getAttendanceModel() -> [Attendance] {
    return store.attendanceByTeam[store.selectTeamID] ?? store.attendanceModel
  }

  @ViewBuilder
  private func AttendanceScrollView(attendanceModel: [Attendance]) -> some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: .zero) {
        ForEach(attendanceModel, id: \.userID) { item in
          AttendanceCard(item: item)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 10)
    }
    .scrollIndicators(.hidden)
    .onAppear {
      UIScrollView.appearance().bounces = false
    }
  }

  @ViewBuilder
  private func AttendanceCard(item: Attendance) -> some View {
    AttendanceCheckStatusCard(
      attendanceStatus: item.status,
      selectPart: item.selectPartEntity ?? .all,
      selectTeam: item.selectTeamEntity ?? .unknown,
      name: item.userName,
      editAction: {
        store.send(
          .view(
            .showEditAttendanceModal(
              id: item.id,
              userId: item.userID
            )
          )
        )
      }
    )
  }

  @ViewBuilder
  func noMemberAttendanceView() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: UIScreen.screenHeight * 0.08)

      VStack {
        Spacer()

        Image(asset: .stamp)
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)

        Spacer()
          .frame(height: 12)

        Text("아직 출석 인원이 없어요.")
          .dddFont(.body1NormalMedium)
          .foregroundStyle(.textSecondary)

        Spacer()
      }
    }
  }
}

private struct TeamTextWidthPreferenceKey: PreferenceKey {
  static var defaultValue: [Int: CGFloat] = [:]

  static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
    value.merge(nextValue(), uniquingKeysWith: { $1 })
  }
}
