//
//  AttendanceCheckView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/16/25.
//

import SwiftUI

import Shareds

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
      store.send(.async(.onAppear))
      
    }
    .onChange(of: store.selectPart ?? .web1) { oldValue, newValue in
      store.selectPart = newValue
      store.send(.inner(.fillterAttendance(team: newValue)))
    }
    .sheet(item: $store.scope(state: \.destination?.scheduleModal, action: \.destination.scheduleModal)) { scheduleModalStore in
      ScheduleModalView(store: scheduleModalStore)
        .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.hidden)

    }
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
    let attendanceCountDTOData = store.attendanceCountDTOModel
    LazyVStack {
      Spacer()
        .frame(height: 14)

      AttendanceCard(
        attendanceCount: attendanceCountDTOData?.presentCount ?? .zero,
        lateCount: attendanceCountDTOData?.lateCount ?? .zero,
        absentCount: attendanceCountDTOData?.absentCount ?? .zero,
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
              ForEach(SelectTeam.attandanceList, id: \.self) { item in
                VStack(spacing: .zero) {
                  HStack {
                    Spacer()
                      .frame(width: 16)

                    Text("\(item.attendanceListDescription)")
                      .pretendardFont(family: .Bold, size: 16)
                      .foregroundColor(store.selectPart == item ? .staticWhite : .gray600)
                      .background(
                        GeometryReader { geometry in
                          Color.clear
                            .preference(key: TextWidthPreferenceKey.self, value: [item: geometry.size.width])
                        }
                      )

                    Spacer()
                      .frame(width: 16)
                  }

                  Spacer()
                    .frame(height: 12)

                  if store.selectPart == item {
                    Divider()
                      .frame(width: store.dividerWidths[item] ?? 0, height: 2)
                      .background(.blue40)
                  }
                }
                .onPreferenceChange(TextWidthPreferenceKey.self) { newWidths in
                  for (key, width) in newWidths {
                    store.dividerWidths[key] = width
                  }
                }
                .onTapGesture {
                  store.send(.view(.selectPartButton(selectPart: item)))
                }
                .id(item)
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
        .onChange(of: store.selectPart) { oldValue, newValue in
          proxy.scrollTo(newValue, anchor: .center)
        }

      }
    }
  }

  @ViewBuilder
  fileprivate func selectPartAttendanceStatus() -> some View {
    if let selectPart = store.selectPart,
       [.web1, .web2, .and1, .and2, .ios1, .ios2].contains(selectPart) {
      selectPartAttandanceStatusCard()
      
      Spacer()
        .frame(height: 20)
    } else {
      selectPartAttandanceStatusCard()
    }
  }

  @ViewBuilder
  fileprivate func selectPartAttandanceStatusCard() -> some View {
    let filtered = store.scheduleModelAttendanceModel?.data.flatMap {
      $0.attendancesSummary.filter { item in
        guard let team = SelectTeam(rawValue: item.profile.team.rawValue),
              let selected = store.selectPart else { return false }
        return team == selected
      }
    } ?? []

    if filtered.isEmpty {
      noMemberAttandanceView()
    } else {
      ScrollView(.vertical) {
        LazyVStack(spacing: .zero) {
          ForEach(filtered, id: \.profile.id) { item in
            AttendanceCheckStatusCard(
              attandanceType: AttendanceType(rawValue: item.status) ?? .present,
              selectPart: SelectPart(rawValue:  item.profile.role) ?? .all,
              selectTeam: item.profile.team,
              name: item.profile.name
            )
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
  }

  @ViewBuilder
  fileprivate func noMemberAttandanceView() -> some View {
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

