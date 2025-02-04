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
    }
    .sheet(item: $store.scope(state: \.destination?.selectDate, action: \.destination.selectDate)) { selectDateStore in
      SelectDateView(store: selectDateStore)
        .presentationDetents([.height(UIScreen.screenHeight * 0.6)])
        .presentationCornerRadius(20)
      
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
                    
                    Text("\(item.attendanceListDesc)")
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
    switch store.selectPart {
    case .web1:
      selectPartAttandanceStatusCard()
    case .web2:
      selectPartAttandanceStatusCard()
    case .and1:
      selectPartAttandanceStatusCard()
    case .and2:
      selectPartAttandanceStatusCard()
    case .ios1:
      selectPartAttandanceStatusCard()
    case .ios2:
      selectPartAttandanceStatusCard()
    default:
      EmptyView()
    }
  }
  
  @ViewBuilder
  fileprivate func selectPartAttandanceStatusCard() -> some View {
    LazyVStack {
      VStack {
        ForEach(
          store.attendanceCheckInModel
            .filter { $0.memberTeam.desc == store.selectPart?.desc ?? "" }
            .sorted { first, second in
              // 정렬 우선순위 배열
              let priority: [AttendanceType] = [
                .present, .disease, .earlyLeave, .late, .absent, .run, .notAttendance
              ]
              
              // 우선순위에 따른 비교 정렬
              guard let firstPriority = priority.firstIndex(of: first.status ?? .notAttendance),
                    let secondPriority = priority.firstIndex(of: second.status ?? .notAttendance) else {
                return false
              }
              return firstPriority < secondPriority
            },
          id: \.id
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
}

