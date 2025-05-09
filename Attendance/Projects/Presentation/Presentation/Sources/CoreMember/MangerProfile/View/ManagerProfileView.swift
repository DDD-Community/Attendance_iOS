//
//  ManagerProfileView.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/17/24.
//

import SwiftUI

import Model

import ComposableArchitecture
import SDWebImageSwiftUI

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
        mangerProfileLoadingData()
      }
      .task {
        store.send(.async(.fetchUser))
      }
      
      if store.destination?.createApp != nil {
        VisualEffectBlur(blurStyle: .systemChromeMaterialDark)
          .edgesIgnoringSafeArea(.top)
           .transition(.opacity)
           .animation(.easeInOut(duration: 0.25), value: store.destination?.createApp != nil)
       }
    }
    .sheet(item: $store.scope(state: \.destination?.createApp, action: \.destination.createApp)) { crateAppStore in
      CreateAppView(store: crateAppStore) {
        store.send(.view(.closeModal))
      }
      .presentationDetents([.height(UIScreen.screenHeight * 0.6)])
      .presentationCornerRadius(20)
      .presentationDragIndicator(.visible)
    }
  }
}

extension ManagerProfileView {
  
  @ViewBuilder
  fileprivate func mangerProfileLoadingData() -> some View {
    if store.userMember?.name ==  nil {
      if store.isLoading  {
        profileLoadingView()
      }
  } else {
    mangerProfileData()
  }
}
  
  @ViewBuilder
  fileprivate func mangerProfileData() -> some View {
    VStack {
      Spacer()
        .frame(height: 12)
      
      CustomNavigationBar(backAction: backAction, addAction: {
        store.send(.view(.appearModal))
      }, image: .info)
      
      mangerCardImage()
      
      logoutButton()
    }
  }
  
  
  @ViewBuilder
  fileprivate func mangerCardImage() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 17)
      
      VStack(alignment: .leading, spacing: .zero) {
        Spacer()
          .frame(height: 24)
        
        if store.userMember?.memberType == .coreMember {
          HStack {
            Text("운영진")
              .pretendardCustomFont(textStyle: .body3NormalBold)
              .foregroundStyle(.statusFocus)
              .padding(.horizontal, 14)
              .padding(.vertical, 5)
              .overlay {
                RoundedRectangle(cornerRadius: 20)
                  .stroke(.statusFocus, lineWidth: 1)
                  .background(.clear)
              }
            
            Spacer()
          }
          
          Spacer()
            .frame(height: 8)
        }
        
       
        
        Text("\(store.userMember?.name ?? "")님")
          .pretendardCustomFont(textStyle: .headline5Bold)
          .foregroundStyle(.borderInverse)
        
        Spacer()
        
        managerTextComponent(
          title: store.managerProfileRoleType,
          subTitle: store.userMember?.role.attendanceListDesc ?? "",
          managingTeam: "",
          isManaging: false,
          isGeneration: false
        )
        
        Spacer()
          .frame(height: 20)
        
        if store.userMember?.memberType == .coreMember {
          if store.userMember?.managing == .projectTeamManaging {
            managerTextComponent(
              title: store.managerProfileManaging,
              subTitle: store.userMember?.managing.managingDesc ?? "",
              managingTeam: store.userMember?.memberTeam?.attendanceListDescription ?? "",
              isManaging: false,
              isGeneration: false
            )
          } else {
            managerTextComponent(
              title: store.managerProfileManaging,
              subTitle: store.userMember?.managing.managingDesc ?? "",
              managingTeam: "",
              isManaging: false,
              isGeneration: false
            )
          }
        }
        else {
          managerTextComponent(
            title: store.memberSelectTeam,
            subTitle: store.userMember?.memberTeam?.attendanceListDescription ?? "",
            managingTeam: "",
            isManaging: false,
            isGeneration: false
          )
        }
        
        Spacer()
          .frame(height: 20)
        
        managerTextComponent(
          title: store.managerProfileGeneration,
          subTitle: store.userMember?.generation.description ?? "",
          managingTeam: "",
          isManaging: false,
          isGeneration: true
        )
        
        Spacer()
          .frame(height: 40)
        
        HStack {
          Spacer()
          
          Text("Dynamic Developer Designers")
            .pretendardCustomFont(textStyle: .body3NormalMedium)
            .foregroundStyle(.textSecondary100)
          
          Spacer()
        }
        
        Spacer()
          .frame(height: 24)
        
      }
      .padding(.horizontal, 24)
      .background(
        Image(asset: .profileBack)
          .resizable()
          .scaledToFit()
          .frame(height: UIScreen.screenHeight * 0.7)
          .cornerRadius(20)
      )
      .frame(height: UIScreen.screenHeight * 0.7)
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
    LazyVStack(spacing: .zero) {
      HStack {
        Text(title)
          .pretendardCustomFont(textStyle: .body2NormalMedium)
          .foregroundStyle(.textSecondary100)
        
        Spacer()
      }
      
      Spacer()
        .frame(height: 2)
      
      if isManaging {
        HStack {
          Text("\(subTitle) / \(managingTeam)팀")
            .pretendardCustomFont(textStyle: .title2NormalBold)
            .foregroundStyle(.borderInverse)
          
          Spacer()
        }
      } else if isGeneration {
        HStack {
          Text("\(subTitle)기")
            .pretendardCustomFont(textStyle: .title2NormalBold)
            .foregroundStyle(.borderInverse)
          
          Spacer()
        }
      } else {
        HStack {
          Text(subTitle)
            .pretendardCustomFont(textStyle: .tilte1NormalBold)
            .foregroundStyle(.borderInverse)
          
          Spacer()
        }
      }
    }
    .padding(.horizontal, 24)
  }
  
  @ViewBuilder
  fileprivate func profileLoadingView() -> some View {
    VStack {
      Spacer()
      
      AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
        .resizable()
        .scaledToFit()
        .frame(width: 200, height: 200)
      
      Spacer()
    }
  }
  
  @ViewBuilder
  private func logoutButton() -> some View {
    VStack {
      Spacer()
        .frame(height: 23)
      
      HStack(alignment: .center) {
        Text(store.logoutText)
          .pretendardCustomFont(textStyle: .body2NormalMedium)
          .foregroundStyle(.staticWhite)
          .underline(true, color: .staticWhite)
      }
      .onTapGesture {
        store.send(.navigation(.presentLogOut))
      }
      
      Spacer()
        
    }
    .padding(.horizontal, 24)
  }
}
