//
//  ManagerProfileView.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/17/24.
//

import SwiftUI

import DesignSystem

import ComposableArchitecture
import Model

public struct ManagerProfileView: View {
  @Bindable private var store: StoreOf<ManagerProfile>
  private var backAction: () -> Void
  
  public init(
    store: StoreOf<ManagerProfile>,
    backAction: @escaping () -> Void
  ) {
    self.store = store
    self.backAction = backAction
  }
  
  public var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        Spacer()
          .frame(height: 16)
        
        CustomNavigationBar(backAction: backAction, addAction: {
          store.send(.navigation(.presentCreatByApp))
        }, image: .pet)
        
        
        managerProfile()
        
        logoutButton()
        
      }
      .task {
        store.send(.async(.fetchUser))
      }
    }
  }
}

extension ManagerProfileView {
  @ViewBuilder
  private func managerProfile() -> some View {
    VStack {
      managerProfileName(
        name: store.userMember?.name ?? "",
        memberType: MemberType(
          rawValue: store.userMember?.memberType.memberDesc ?? ""
        ) ?? .coreMember
      )
      
      managerTextComponent(
        title: store.managerProfileRoleType,
        subTitle: store.userMember?.role.attendanceListDesc ?? "",
        managingTeam: "",
        isManaging: false,
        isGeneration: false
      )
      
      managerTextComponent(
        title: store.managerProfileManaging,
        subTitle:  store.userMember?.managing.managingDesc ?? "",
        managingTeam: "",
        isManaging: false,
        isGeneration: false
      )
      
      managerTextComponent(
        title: store.managerProfileGeneration,
        subTitle: "\(store.userMember?.generation ?? .zero)",
        managingTeam: "",
        isManaging: false,
        isGeneration: true
      )
    }
  }
  
  @ViewBuilder
  private func managerProfileName(
    name: String,
    memberType: MemberType
  ) -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 30)
      
      HStack {
        Text("\(name)\(store.managerProfileName)")
          .pretendardFont(family: .SemiBold, size: 24)
          .foregroundStyle(.staticWhite)
        
        Spacer()
          .frame(width: 8)
        
        if memberType == .coreMember {
          RoundedRectangle(cornerRadius: 8)
            .fill(.gray800)
            .frame(width: 54, height: 24)
            .overlay {
              Text(memberType.memberDesc)
                .pretendardFont(family: .Regular, size: 14)
                .foregroundStyle(Color.basicBlue)
            }
        }
        
        Spacer()
      }
    }
    .padding(.horizontal, 24)
  }
  
  @ViewBuilder
  private func managerTextComponent(
    title: String,
    subTitle: String,
    managingTeam: String,
    isManaging: Bool,
    isGeneration: Bool
  ) -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 16)
      
      HStack {
        Text(title)
          .pretendardFont(family: .SemiBold, size: 14)
          .foregroundStyle(.gray600)
        
        Spacer()
      }
      
      Spacer()
        .frame(height: 8)
      
      if isManaging {
        HStack {
          Text("\(subTitle) / \(managingTeam)팀")
            .pretendardFont(family: .SemiBold, size: 24)
            .foregroundStyle(.staticWhite)
          
          Spacer()
        }
      } else if isGeneration {
        HStack {
          Text("\(subTitle)기")
            .pretendardFont(family: .SemiBold, size: 24)
            .foregroundStyle(.staticWhite)
          
          Spacer()
        }
      } else {
        HStack {
          Text(subTitle)
            .pretendardFont(family: .SemiBold, size: 24)
            .foregroundStyle(.staticWhite)
          
          Spacer()
        }
      }
    }
    .padding(.horizontal, 24)
  }
  
  @ViewBuilder
  private func logoutButton() -> some View {
    VStack {
      Spacer()
      
      HStack(alignment: .center) {
        Text(store.logoutText)
          .pretendardFont(family: .Regular, size: 16)
          .foregroundStyle(.gray300)
          .underline(true, color: Color.gray300)
      }
      .onTapGesture {
        store.send(.navigation(.tapLogOut))
      }
      
      Spacer()
        .frame(height: 24)
    }
    .padding(.horizontal, 24)
  }
}
