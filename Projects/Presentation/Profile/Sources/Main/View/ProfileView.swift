//
//  ManagerProfileView.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/17/24.
//

import SwiftUI


import ComposableArchitecture
import SDWebImageSwiftUI
import DesignSystem

public struct ProfileView: View {
  @Bindable private var store: StoreOf<ProfileReducer>
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
      .customConfirmationPopup(
        item: store.alertItem.map { alertItem in
          AlertItem(
            title: alertItem.title,
            message: alertItem.message,
            confirmTitle: alertItem.confirmTitle,
            cancelTitle: alertItem.cancelTitle,
            isDestructive: alertItem.isDestructive,
            onConfirm: {
              store.send(.view(.withdrawAlertConfirmed))
            },
            onCancel: {
              store.send(.view(.withdrawAlertCancelled))
            }
          )
        }
      )
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
        store.send(.view(.closeModal))
      }
      .presentationDetents([.height(UIScreen.screenHeight * 0.6)])
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
          store.send(.view(.appearModal))
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
        store.send(.view(.appearModal))
      }, image: .info)

      mangerCardImage()

      logoutButton()

      appInfoView()
    }
  }

  @ViewBuilder
  fileprivate func mangerCardImage() -> some View {
    let team = store.profileModel?.team ?? .unknown

    LazyVStack {
      Spacer()
        .frame(height: 17)

      VStack(alignment: .leading, spacing: .zero) {
        if store.profileModel?.role == .manager {
          Spacer()
            .frame(height: 24)
        }

        HStack {
          Text(store.profileModel?.role == .manager ? "매니저" : "멤버")
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

          HStack {
            Image(asset: .edit)
              .resizable()
              .scaledToFit()
              .frame(width: 13, height: 15)

            Spacer()
              .frame(width: 7)

            Text("기수 변경")
              .pretendardCustomFont(textStyle: .body3NormalMedium)
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

        Text("\(store.profileModel?.name ?? "")님")
          .pretendardCustomFont(textStyle: .headline5Bold)
          .foregroundStyle(.borderInverse)

        if store.profileModel?.role == .manager {
          Spacer()
            .frame(height: 20)
        } else {
          Spacer()
        }

        VStack(alignment: .leading, spacing: 20) {
          // 1. 직군 (항상 표시)
          managerTextComponent(
            title: store.managerProfileRoleType,
            subTitle: store.profileModel?.jobRole.desc ?? "",
            managingTeam: "",
            isManaging: false,
            isGeneration: false
          )

          if store.profileModel?.role == .manager {
            // Manager 순서: 직군 → 담당 팀 → 소속 기수 → 담당 업무

            // 2. 담당 팀
            managerTextComponent(
              title: store.memberSelectTeam,
              subTitle: "매니징",
              managingTeam: team.attendanceListDescription,
              isManaging: true,
              isGeneration: false
            )

            // 3. 소속 기수
            managerTextComponent(
              title: store.managerProfileGeneration,
              subTitle: store.profileModel?.generation ?? "",
              managingTeam: "",
              isManaging: false,
              isGeneration: true
            )

            // 4. 담당 업무 (해당 업무가 있는 경우만)
            if let managerRoles = store.profileModel?.manger, !managerRoles.isEmpty {
              managerTextComponent(
                title: store.managerProfileManaging,
                subTitle: managerRoles.map { $0.desc }.joined(separator: " / "),
                managingTeam: "",
                isManaging: false,
                isGeneration: false
              )
            }

          } else if store.profileModel?.role == .member {
            // Member 순서: 직군 → 소속 팀 → 소속 기수

            // 2. 소속 팀
            managerTextComponent(
              title: store.memberSelectTeam,
              subTitle: team.attendanceListDescription,
              managingTeam: "",
              isManaging: false,
              isGeneration: false
            )

            // 3. 소속 기수
            managerTextComponent(
              title: store.managerProfileGeneration,
              subTitle: store.profileModel?.generation ?? "",
              managingTeam: "",
              isManaging: false,
              isGeneration: true
            )
          }

        }

        Spacer()
         

        HStack {
          Spacer()

          Text("Dynamic Developer Designers")
            .pretendardCustomFont(textStyle: .body3NormalMedium)
            .foregroundStyle(.textSecondary100)

          Spacer()
        }

        if store.profileModel?.role == .manager {
          Spacer()
            .frame(height: 24)
        }
      }
      .padding(24)
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
          Text("\(subTitle) / \(managingTeam)")
            .pretendardCustomFont(textStyle: .title2NormalMedium)
            .foregroundStyle(.borderInverse)

          Spacer()
        }
      } else if isGeneration {
        HStack {
          Text("\(subTitle)")
            .pretendardCustomFont(textStyle: .title2NormalMedium)
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
              .pretendardCustomFont(textStyle: .title2NormalMedium)
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
          .pretendardCustomFont(textStyle: .body2NormalMedium)
          .foregroundStyle(.mediumGray)
          .underline(true, color: .mediumGray)
          .onTapGesture {
            store.send(.view(.showWithdrawAlert))
          }

      Spacer()
          .frame(width: 64)

        Text(store.logoutText)
          .pretendardCustomFont(textStyle: .body2NormalMedium)
          .foregroundStyle(.staticWhite)
          .underline(true, color: .staticWhite)
          .onTapGesture {
            store.send(.async(.logout))
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
        .pretendardCustomFont(textStyle: .body3NormalRegular)
        .foregroundStyle(.mediumGray100)

      Spacer()
        .frame(height: 4)

      Text("개인정보처리방침 보기")
        .pretendardCustomFont(textStyle: .body3NormalRegular)
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

