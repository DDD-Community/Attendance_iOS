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
    }
    .padding(.horizontal, 24)
  }
  
  @ViewBuilder
  fileprivate func attandanceStatusView() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 14)
      
      AttendanceCard(
        attendanceCount: 1,
        lateCount: 2,
        absentCount: 4,
        isManager: true)
    }
    .padding(.horizontal, 24)
  }
}

