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
      .task {
        store.send(.async(.fetchUser))
      }
      .alert($store.scope(state: \.alert, action: \.scope.alert))
      .customConfirmationPopup(
        item: store.alertItem != nil ? AlertItem(
          title: store.alertItem?.title ?? "",
          message: store.alertItem?.message ?? "",
          confirmTitle: store.alertItem?.confirmTitle ?? "확인",
          cancelTitle: store.alertItem?.cancelTitle ?? "취소",
          isDestructive: store.alertItem?.isDestructive ?? false,
          onConfirm: {
            store.send(.view(.withdrawAlertConfirmed))
          },
          onCancel: {
            store.send(.view(.withdrawAlertCancelled))
          }
        ) : nil
      )

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
//    if store.profileDTOModel == nil {
//      if store.isLoading  {
//        VStack {
//          Spacer()
//            .frame(height: 12)
//
//          CustomNavigationBar(backAction: backAction, addAction: {
//            store.send(.view(.appearModal))
//          }, image: .info)
//
//          Spacer()
//
//          profileLoadingView()
//
//          Spacer()
//
//          logoutButton()
//
//
//        }
//      }
//    } else {
//      mangerProfileData()
//    }
    mangerProfileData()
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

        HStack {
          Text("멤버")
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

          
        }

        Text("\(store.profileModel?.name ?? "")님")
          .pretendardCustomFont(textStyle: .headline5Bold)
          .foregroundStyle(.borderInverse)

        Spacer()

        VStack(alignment: .leading, spacing: 20) {
          managerTextComponent(
            title: store.managerProfileRoleType,
            subTitle: store.profileModel?.jobRole.desc ?? "",
            managingTeam: "",
            isManaging: false,
            isGeneration: false
          )

//          if store.profileModel?.isStaff == true {
////            managerTextComponent(
////              title: store.managerProfileManaging,
////              subTitle: store.profileModel?.responsibility.managingDesc ?? "",
////              managingTeam: team.attendanceListDescription,
////              isManaging: store.profileModel?.responsibility == .projectTeamManaging ? true : false,
////              isGeneration: false
////            )
//          } else {
//            managerTextComponent(
//              title: store.memberSelectTeam,
//              subTitle: team.attendanceListDescription,
//              managingTeam: "",
//              isManaging: false,
//              isGeneration: false
//            )
//          }

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

        Spacer()
          .frame(height: 40)

        HStack {
          Spacer()

          Text("Dynamic Developer Designers")
            .pretendardCustomFont(textStyle: .body3NormalMedium)
            .foregroundStyle(.textSecondary100)

          Spacer()
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
          Text("\(subTitle)기")
            .pretendardCustomFont(textStyle: .title2NormalMedium)
            .foregroundStyle(.borderInverse)

          Spacer()
        }
      } else {
        HStack {
          Text(subTitle)
            .pretendardCustomFont(textStyle: .title2NormalMedium)
            .foregroundStyle(.borderInverse)

          Spacer()
        }
      }
    }
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
        .frame(height: 40)
    }
  }
}

