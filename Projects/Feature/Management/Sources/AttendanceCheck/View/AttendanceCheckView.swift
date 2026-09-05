//
//  AttendanceCheckView.swift
//  Presentation
//
//  Created by DDD on 1/16/25.
//

import AttendanceDomainInterface
import DDDAccessibility
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
        .padding(.bottom, 20)
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(ManagementAccessibilityID.Attendance.root)
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
    VStack { // LazyVStack → VStack
      Spacer().frame(height: 24)

      HStack {
        Image(asset: .calender)
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 26)

        Spacer().frame(width: 4)

        Text(store.selectedAttendanceDate.formatted(.yearMonthDayDotted))
          .dddFont(.body1NormalMedium)
          .foregroundStyle(.staticWhite)

        Spacer()
      }
      .contentShape(Rectangle()) // 탭 영역 확보(빈 곳도 탭되게)
      .onTapGesture {
        send(.tapSelectDate)
      }
      .dddAccessibilityID(ManagementAccessibilityID.Attendance.dateButton)
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
      .dddAccessibilityID(ManagementAccessibilityID.Attendance.summary)
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
  }

  @ViewBuilder
  func teamTabScroller(proxy: ScrollViewProxy) -> some View {
    VStack {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(store.teams) { item in
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
    .onChange(of: store.selectedTeamID) { _, selectedTeamID in
      guard let selectedTeamID,
            let target = store.teams[id: selectedTeamID]
      else { return }
      withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        proxy.scrollTo(target.id, anchor: .center)
      }
    }
  }

  @ViewBuilder
  func teamTabItem(item: SelectTeamEntity) -> some View {
    let isSelected = store.selectedTeamID == item.teamId

    VStack(spacing: .zero) {
      HStack {
        Spacer().frame(width: 16)

        Text(item.teams.attendanceListDescription)
          .pretendardFont(family: .Bold, size: 16)
          .foregroundColor(isSelected ? .staticWhite : .gray600)
          .animation(.easeInOut(duration: 0.25), value: store.selectedTeamID)
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
    .dddAccessibilityID(ManagementAccessibilityID.Attendance.team(item.teamId))
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
          .frame(width: store.teamTabWidths[itemID] ?? 0, height: 2)
          .matchedGeometryEffect(id: "teamTabUnderline", in: teamTabNamespace)
      } else {
        Color.clear.frame(height: 2)
      }
    }
  }

  @ViewBuilder
  func selectPartAttendanceStatus() -> some View {
    switch store.viewState {
    case .idle, .loading, .refreshingAttendanceList:
      attendanceStatusCardSkeletonList()
        .transition(.opacity)

    case .loaded:
      attendanceTabView()
        .transition(.opacity)
    }
  }

  @ViewBuilder
  func attendanceStatusCardSkeletonList() -> some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: .zero) {
        ForEach(0 ..< 6, id: \.self) { _ in
          attendanceStatusCardSkeleton()
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 10)
    }
    .scrollIndicators(.hidden)
    .animation(.easeInOut(duration: 0.2), value: store.viewState)
    .dddAccessibilityID(ManagementAccessibilityID.Attendance.listSkeleton)
  }

  @ViewBuilder
  func attendanceStatusCardSkeleton() -> some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
          .frame(width: 72, height: 22)

        SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
          .frame(width: 112, height: 17)
      }

      Spacer()

      SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
        .frame(width: 36, height: 17)

      SkeletonView(.circle)
        .frame(width: 24, height: 24)

      SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
        .frame(width: 15, height: 15)
    }
    .padding(.horizontal, 20)
    .frame(height: 84)
    .background(.borderInverse)
    .clipShape(.rect(cornerRadius: 15))
  }

  @ViewBuilder
  func attendanceTabView() -> some View {
    TabView(selection: pageSelection) {
      ForEach(store.pageTeams) { team in
        selectPartAttendanceStatusCard(team: team)
          .tag(team.teamId)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
  }

  var pageSelection: Binding<Int> {
    Binding(
      get: { store.selectedTeamID ?? store.pageTeams.first?.teamId ?? 0 },
      set: { send(.pageChanged(teamID: $0)) }
    )
  }

  @ViewBuilder
  func selectPartAttendanceStatusCard(team: SelectTeamEntity) -> some View {
    let attendanceModel = attendanceModels(for: team)

    if attendanceModel.isEmpty {
      noMemberAttendanceView()
    } else {
      AttendanceScrollView(attendanceModel: attendanceModel)
    }
  }

  private func attendanceModels(for team: SelectTeamEntity) -> [Attendance] {
    store.attendanceByTeam[team.teamId] ?? []
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
    .dddAccessibilityID(ManagementAccessibilityID.Attendance.list)
  }

  @ViewBuilder
  private func AttendanceCard(item: Attendance) -> some View {
    AttendanceCheckStatusCard(
      attendanceStatus: item.status,
      selectPart: item.selectPartEntity ?? .all,
      selectTeam: item.selectTeamEntity ?? .unknown,
      name: item.userName,
      accessibilityID: ManagementAccessibilityID.Attendance.card(userID: item.userID),
      editAccessibilityID: ManagementAccessibilityID.Attendance.cardEditButton(userID: item.userID),
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
