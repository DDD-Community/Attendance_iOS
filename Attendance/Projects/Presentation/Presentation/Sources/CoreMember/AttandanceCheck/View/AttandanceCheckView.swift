//
//  AttandanceCheckView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/16/25.
//

import SwiftUI

import Shareds

import ComposableArchitecture

struct AttandanceCheckView: View {
  @Bindable var store: StoreOf<AttandanceCheck>
  
  var body: some View{
    VStack {
      selectAttandanceDate()
      
      attandanceStatusView()
      
      selectPartType()
      
      
      selectPartAttandanceStatus()
    }
    .task {
      store.send(.async(.fetchAttenDance))
      store.send(.async(.observeAttendance))
//      store.send(.async(.filterAndSortAttendance))
    }
    .sheet(item: $store.scope(state: \.destination?.selectDate, action: \.destination.selectDate)) { selectDateStore in
      VStack {
        Spacer()
          .frame(height: 20)
        
        CustomFSCalendarView(selectDate: $store.selectAttandanceDate, currentMonth: $store.selectAttandanceDateMonth)
          .padding(.horizontal, 24)
          .frame(height: 200)
        
        Spacer()
      }
      
    }
  }
}


extension AttandanceCheckView {
  
  @ViewBuilder
  fileprivate func selectAttandanceDate() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 24)
      
      HStack {
        Text("🗓️")
          .pretendardCustomFont(textStyle: .body1NormalMedium)
        
        Spacer()
          .frame(width: 4)
        
        Text("\(store.selectAttandanceDate.formattedDateTimeText(date: store.selectAttandanceDate))")
          .pretendardCustomFont(textStyle: .body1NormalMedium)
          .foregroundStyle(.staticWhite)
        
        Spacer()
      }
      .onTapGesture {
        store.send(.view(.appearSelectDate))
      }
    }
    .padding(.horizontal, 24)
  }
  
  @ViewBuilder
  fileprivate func attandanceStatusView() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 14)
      
      AttendanceCard(
        attendanceCount: store.attendanceCount,
        lateCount: store.lateCount,
        absentCount: store.absentCount,
        isManager: true)
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
  fileprivate func selectPartAttandanceStatus() -> some View {
    if let selectPart = store.selectPart,
       [.web1, .web2, .and1, .and2, .ios1, .ios2].contains(selectPart) {
      if store.attendaceMemberModel.filter({ $0.memberTeam.description == store.selectPart?.description}).isEmpty {
        noMemberAttandanceView()
      } else {
        selectPartAttandanceStatusCard()
      }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  fileprivate func selectPartAttandanceStatusCard() -> some View {
    LazyVStack {
      VStack {
        ForEach(
          store.attendanceCheckInModel
            .filter { $0.memberTeam.description == store.selectPart?.description }
          ,id: \.id
        ) { item in
          AttendanceCheckStatusCard(
            attandanceType: item.status ?? .notAttendance,
            selectPart: item.roleType,
            selectTeam: item.memberTeam,
            name: item.name
          )
        }
      }
      .padding(.horizontal, 24)
    }
  }
  
  @ViewBuilder
  fileprivate func noMemberAttandanceView() -> some View {
    LazyVStack {
      
      Spacer()
        .frame(height: 20)
      
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

