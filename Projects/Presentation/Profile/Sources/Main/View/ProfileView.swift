//
//  ManagerProfileView.swift
//  DDDAttendance
//
//  Created by DDD on 7/17/24.
//

import DDDCoreUI
import SwiftUI

import ComposableArchitecture
import DDDDesignKit

@ViewAction(for: ProfileReducer.self)
public struct ProfileView: View {
  @Bindable public var store: StoreOf<ProfileReducer>
  private var backAction: () -> Void

  public init(
    store: StoreOf<ProfileReducer>,
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
      .alert($store.scope(state: \.alert, action: \.scope.alert))
      .dddAlert($store.scope(state: \.customAlert, action: \.scope.customAlert))
      .onAppear {
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
        send(.closeModal)
      }
      .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
      .presentationCornerRadius(20)
      .presentationDragIndicator(.visible)
    }
  }
}

extension ProfileView {
  @ViewBuilder
  fileprivate func mangerProfileLoadingData() -> some View {
    if store.profileModel == nil && store.isLoading {
      VStack {
        Spacer()
          .frame(height: 12)

        CustomNavigationBar(backAction: backAction, addAction: {
          send(.appearModal)
        }, image: .info)

        ProfileSkeletonView()
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
        send(.appearModal)
      }, image: .info)

      mangerCardImage()

      logoutButton()

      appInfoView()

      Spacer()
    }
  }

  @ViewBuilder
  fileprivate func mangerCardImage() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 17)

      profileCardContent
        .padding(24)
        .background(profileCardBackground)
        .frame(height: UIScreen.screenHeight * 0.65)
    }
    .padding(.horizontal, 24)
  }

  private var profileCardContent: some View {
    VStack(alignment: .leading, spacing: .zero) {
      if store.profileModel?.role == .manager {
        Spacer()
          .frame(height: 24)
      }

      profileHeader
      profileName
      profileSpacingAfterName
      profileInfoContent
      profileBottomSpacer
      profileFooter

      if store.profileModel?.role == .manager {
        Spacer()
          .frame(height: 24)
      }
    }
  }

  private var profileHeader: some View {
    HStack {
      profileRoleBadge
      Spacer()
      generationEditButton
    }
  }

  private var profileRoleBadge: some View {
    Text(store.profileModel?.role == .manager ? "매니저" : "멤버")
      .dddFont(.body3NormalBold)
      .foregroundStyle(.statusFocus)
      .padding(.horizontal, 14)
      .padding(.vertical, 5)
      .overlay {
        RoundedRectangle(cornerRadius: 20)
          .stroke(.statusFocus, lineWidth: 1)
          .background(.clear)
      }
  }

  private var generationEditButton: some View {
    HStack {
      Image(asset: .edit)
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 13, height: 15)

      Spacer()
        .frame(width: 7)

      Text("기수 변경")
        .dddFont(.body3NormalMedium)
        .foregroundStyle(.staticWhite)
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 10)
    .background {
      RoundedRectangle(cornerRadius: 20)
        .fill(.dangerBlue.opacity(0.7))
    }
    .onTapGesture {
      store.send(.navigation(.presentEditGeneration))
    }
  }

  private var profileName: some View {
    Text("\(store.profileModel?.name ?? "")님")
      .dddFont(.headline5Bold)
      .foregroundStyle(.borderInverse)
  }

  private var profileSpacingAfterName: some View {
    Group {
      if store.profileModel?.role == .manager {
        Spacer()
          .frame(height: 20)
      } else {
        Spacer()
      }
    }
  }

  private var profileInfoContent: some View {
    VStack(alignment: .leading, spacing: 20) {
      jobRoleComponent

      if store.profileModel?.role == .manager {
        managerSpecificComponents
      } else if store.profileModel?.role == .member {
        memberSpecificComponents
      }
    }
  }

  private var jobRoleComponent: some View {
    managerTextComponent(
      title: store.managerProfileRoleType,
      subTitle: store.profileModel?.jobRole.desc ?? "",
      managingTeam: "",
      isManaging: false,
      isGeneration: false
    )
  }

  private var managerSpecificComponents: some View {
    let team = store.profileModel?.team ?? .unknown

    return Group {
      managerTextComponent(
        title: store.memberSelectTeam,
        subTitle: "매니징",
        managingTeam: team.attendanceListDescription,
        isManaging: true,
        isGeneration: false
      )

      managerTextComponent(
        title: store.managerProfileGeneration,
        subTitle: store.profileModel?.generation ?? "",
        managingTeam: "",
        isManaging: false,
        isGeneration: true
      )

      if let managerRoles = store.profileModel?.manger, !managerRoles.isEmpty {
        managerTextComponent(
          title: store.managerProfileManaging,
          subTitle: managerRoles.map { $0.desc }.joined(separator: " / "),
          managingTeam: "",
          isManaging: false,
          isGeneration: false
        )
      }
    }
  }

  private var memberSpecificComponents: some View {
    let team = store.profileModel?.team ?? .unknown

    return Group {
      managerTextComponent(
        title: store.memberSelectTeam,
        subTitle: team.attendanceListDescription,
        managingTeam: "",
        isManaging: false,
        isGeneration: false
      )

      managerTextComponent(
        title: store.managerProfileGeneration,
        subTitle: store.profileModel?.generation ?? "",
        managingTeam: "",
        isManaging: false,
        isGeneration: true
      )
    }
  }

  private var profileBottomSpacer: some View {
    Group {
      if store.profileModel?.role == .manager {
        Spacer()
      } else {
        Spacer()
          .frame(height: 40)
      }
    }
  }

  private var profileFooter: some View {
    HStack {
      Spacer()
      Text("Dynamic Developer Designers")
        .dddFont(.body3NormalMedium)
        .foregroundStyle(.textSecondary100)
      Spacer()
    }
  }

  private var profileCardBackground: some View {
    Image(asset: .profileBack)
      .resizable()
      .cornerRadius(20)
      .padding(.horizontal, 10)
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
          .dddFont(.body2NormalMedium)
          .foregroundStyle(.textSecondary100)

        Spacer()
      }

      Spacer()
        .frame(height: 2)

      if isManaging {
        HStack {
          Text("\(subTitle) / \(managingTeam)")
            .dddFont(.title2NormalMedium)
            .foregroundStyle(.borderInverse)

          Spacer()
        }
      } else if isGeneration {
        HStack {
          Text("\(subTitle)")
            .dddFont(.title2NormalMedium)
            .foregroundStyle(.borderInverse)

          Spacer()
        }
      } else {
        HStack {
          if title == "담당 업무" {
            Text(subTitle)
              .pretendardFont(family: .Regular, size: 16)
              .foregroundStyle(.textSecondary100)

          } else {
            Text(subTitle)
              .dddFont(.title2NormalMedium)
              .foregroundStyle(.borderInverse)
          }

          Spacer()
        }
      }
    }
  }


  @ViewBuilder
  private func logoutButton() -> some View {
    VStack {
      Spacer()
        .frame(height: 36)

      HStack(alignment: .center) {

        Text("탈퇴하기")
          .dddFont(.body2NormalMedium)
          .foregroundStyle(.mediumGray)
          .underline(true, color: .mediumGray)
          .onTapGesture {
            send(.showWithdrawAlert)
          }

      Spacer()
          .frame(width: 64)

        Text(store.logoutText)
          .dddFont(.body2NormalMedium)
          .foregroundStyle(.staticWhite)
          .underline(true, color: .staticWhite)
          .onTapGesture {
            send(.showLogoutAlert)
          }
      }
    }
    .padding(.horizontal, 24)
  }

  @ViewBuilder
  private func appInfoView() -> some View {
    VStack {
      Spacer()
        .frame(height: 12)


      Text("Version \(store.appVersion)")
        .dddFont(.body3NormalRegular)
        .foregroundStyle(.mediumGray100)

      Spacer()
        .frame(height: 4)

      Text("개인정보처리방침 보기")
        .dddFont(.body3NormalRegular)
        .foregroundStyle(.mediumGray)
        .underline(true, color: .mediumGray)
        .onTapGesture {
          store.send(.navigation(.presentPrivacyPolicy))
        }

      Spacer()
        .frame(height: 20)
    }
  }
}

