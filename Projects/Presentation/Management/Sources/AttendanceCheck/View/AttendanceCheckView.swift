//
//  AttendanceCheckView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/16/25.
//

import SwiftUI

import Shareds
import DesignSystem
import Entity

import ComposableArchitecture

struct AttendanceCheckView: View {
  @Bindable var store: StoreOf<AttendanceCheck>

  var body: some View{
    VStack {
      selectAttendanceDate()

      attendanceStatusView()

      selectPartType()

      selectPartAttendanceStatus()
    }
    .onAppear {
      store.send(.view(.onAppear))
      
    }
    .sheet(item: $store.scope(state: \.destination?.scheduleModal, action: \.destination.scheduleModal)) { scheduleModalStore in
      ScheduleModalView(store: scheduleModalStore)
        .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.visible)

    }
    .alert($store.scope(state: \.alert, action: \.scope.alert))
    .attendanceModal($store.scope(state: \.attendanceModal, action: \.scope.attendanceModal))
  }
}


extension AttendanceCheckView {

  @ViewBuilder
  fileprivate func selectAttendanceDate() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 24)

      HStack {
        Text("🗓️")
          .pretendardCustomFont(textStyle: .body1NormalMedium)

        Spacer()
          .frame(width: 4)

        Text(store.selectAttendanceDate.formattedDateTimeText(date: store.selectAttendanceDate))
          .pretendardCustomFont(textStyle: .body1NormalMedium)
          .foregroundStyle(.staticWhite)

        Spacer()
      }
      .onTapGesture {
        store.send(.view(.tapSelectDate))
      }
    }
    .padding(.horizontal, 24)
  }

  @ViewBuilder
  fileprivate func attendanceStatusView() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 14)

      DesignSystem.AttendanceCard(
        attendanceCount: store.attendanceCount,
        lateCount:  store.lateCount,
        absentCount: store.absentCount,
        showWarning: false
      )
    }
    .padding(.horizontal, 24)
  }

  @ViewBuilder
  fileprivate func selectPartType() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 28)

      ScrollViewReader { proxy in
        VStack {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              ForEach(store.attendanceTeam) { item in
                let mappedTeam = item.teams
                VStack(spacing: .zero) {
                  HStack {
                    Spacer()
                      .frame(width: 16)

                    Text("\(item.teams.attendanceListDescription)")
                      .pretendardFont(family: .Bold, size: 16)
                      .foregroundColor(store.selectPart == mappedTeam ? .staticWhite : .gray600)
                      .background(
                        GeometryReader { geometry in
                          Color.clear
                            .preference(key: TeamTextWidthPreferenceKey.self, value: [item.id: geometry.size.width])
                        }
                      )

                    Spacer()
                      .frame(width: 16)
                  }

                  Spacer()
                    .frame(height: 12)

                  if store.selectPart == mappedTeam {
                    Divider()
                      .frame(width: store.dividerWidths[item.id] ?? 0, height: 2)
                      .background(.blue40)
                  }
                }
                .onPreferenceChange(TeamTextWidthPreferenceKey.self) { newWidths in
                  for (key, width) in newWidths {
                    store.dividerWidths[key] = width
                  }
                }
                .onTapGesture {
                  store.send(.view(.selectPartButton(selectPart: item)))
                }
                .id(item.id)
              }
            }
            .padding(.horizontal, 24)
          }

          Spacer()
            .frame(height: 12)

          Divider()
            .frame(height: 1)
            .background(.borderInactive.opacity(0.12))
            .offset(y: -12)
        }
        .onChange(of: store.selectPart) { _, newValue in
          guard let newValue,
                let target = store.attendanceTeam.first(where: {
                  $0.teams == newValue
                }) else { return }
          proxy.scrollTo(target.id, anchor: .center)
        }

      }
    }
  }

  @ViewBuilder
  fileprivate func selectPartAttendanceStatus() -> some View {
    if let selectPart = store.selectPart,
       [.web1, .web2, .and1, .and2, .ios1, .ios2].contains(selectPart) {
      selectPartAttendanceStatusCard()

      Spacer()
        .frame(height: 20)
    } else {
      selectPartAttendanceStatusCard()
    }
  }

  @ViewBuilder
  fileprivate func selectPartAttendanceStatusCard() -> some View {
    let attendanceModel = getAttendanceModel()

    if attendanceModel.isEmpty {
      noMemberAttendanceView()
    } else {
      AttendanceScrollView(attendanceModel: attendanceModel)
    }
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
  fileprivate func noMemberAttendanceView() -> some View {
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
          .pretendardCustomFont(textStyle: .body1NormalMedium)
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
