//
//  StaffView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import SwiftUI

import DesignSystem
import Model

import ComposableArchitecture
import SDWebImageSwiftUI

struct StaffView: View {
  @Bindable var store: StoreOf<Staff>
  @State var isExpanded: Bool = false

  init(store: StoreOf<Staff>) {
    self.store = store
  }

  var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)

      VStack {
        navigationTrallingButton()

        Spacer()
          .frame(height: 10)

        switchSelectDropDownView()

        Spacer()
      }
    }
    .overlay {
      dropDownView()
    }
    .overlay {
      if shouldShowSkeleton {
        skeletonView
      }
    }
    .allowsHitTesting(!shouldShowSkeleton)
    .onTapGesture {
      if store.isExpandedDropDown {
        withAnimation {
          store.isExpandedDropDown = false
        }
      }
    }

    .gesture(
      DragGesture()
        .onEnded { value in
          if value.translation.width < -UIScreen.screenWidth * 0.02 {
            store.send(.attendanceCheck(.view(.swipeNext)))
          } else if value.translation.width > UIScreen.screenWidth * 0.02 {
            store.send(.attendanceCheck(.view(.swipePrevious)))
          }
        }
    )
    .sheet(item: $store.scope(state: \.destination?.qrcode, action: \.destination.qrcode)) { qrCodeStore in
      QRScannerView(store: qrCodeStore) {
        store.send(.view(.closeModal))
        store.send(.attendanceCheck(.view(.onAppear)))
      }
      .presentationDetents([.height(UIScreen.screenHeight * 0.85)])
      .presentationCornerRadius(20)
      .presentationDragIndicator(.hidden)
    }
    // 투표 모달 — 전체 화면(상단바 포함)을 덮도록 루트에 부착
    .customAlert($store.scope(state: \.vote.customAlert, action: \.vote.scope.customAlert))
    .alert($store.scope(state: \.vote.alert, action: \.vote.scope.alert))
    .nonParticipantsModal(
      isPresented: store.vote.isNonParticipantsPresented,
      isLoading: store.vote.isNonParticipantsLoading,
      members: store.vote.nonParticipants,
      onClose: {
        store.send(.vote(.view(.tappedCloseNonParticipants)))
      }
    )
  }
}

private extension StaffView {
  @ViewBuilder
  func navigationTrallingButton() -> some View {
    VStack {
      Spacer()
        .frame(height: 10)

      HStack(spacing: .zero) {
        Button {
          withAnimation {
            store.isExpandedDropDown.toggle()
          }
        } label: {
          HStack {
            Text(store.selectDropDownItem.desc)
              .pretendardCustomFont(textStyle: .title2NormalBold)
              .foregroundColor(.staticWhite)

            Spacer()
              .frame(width: 10)

            Image(systemName: store.isExpandedDropDown ? "chevron.up" : "chevron.down")
              .renderingMode(.template) // 시스템 이미지 렌더링 최적화
              .foregroundColor(.white)
              .frame(width: 12, height: 7)
              .bold()
          }
          .padding(.leading, 24)
        }

        Spacer()

        Circle()
          .fill(.blue70)
          .frame(width: 36, height: 36)
          .overlay {
            Image(asset: store.qrcodeImage)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .foregroundStyle(.staticWhite)
          }
          .onTapGesture {
            store.send(.view(.presentQrcode))
          }

        Spacer()
          .frame(width: 12)

        Circle()
          .fill(.gray80)
          .frame(width: 36, height: 36)
          .overlay {
            Image(asset: .user)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .foregroundStyle(.staticWhite)
          }
          .onTapGesture {
            store.send(.navigation(.presentManagerProfile))
          }
      }
    }
    .padding(.trailing, 24)
  }

  @ViewBuilder
  func switchSelectDropDownView() -> some View {
    switch store.selectDropDownItem {
    case .attandance:
      AttendanceCheckView(store: store.scope(state: \.attendanceCheck, action: \.attendanceCheck))

    case .schedule:
      ScheduleView(store: store.scope(state: \.schedule, action: \.schedule))

    case .vote:
      VoteView(store: store.scope(state: \.vote, action: \.vote))
    }
  }

  @ViewBuilder
  func dropDownView() -> some View {
    if store.isExpandedDropDown {
      ZStack(alignment: .topLeading) {
        // 반투명 배경 (탭 시 닫힘)
        Color.black.opacity(0.6)
          .ignoresSafeArea()
          .onTapGesture {
            withAnimation {
              store.isExpandedDropDown = false
            }
          }

        HomeDropdownMenu(
          entries: SelectDropDownItem.allCases.map { item in
            HomeDropdownMenu.Entry(
              id: item.rawValue,
              title: item.desc,
              isSelected: item == store.selectDropDownItem,
              showsNewBadge: item == .vote
            )
          },
          onSelect: { entry in
            if let matched = SelectDropDownItem.allCases.first(where: { $0.rawValue == entry.id }) {
              store.selectDropDownItem = matched
            }
            withAnimation {
              store.isExpandedDropDown = false
            }
          }
        )
        .padding(.leading, 24)
        .padding(.top, 52)
      }
      .zIndex(1)
    }
  }
}

private extension StaffView {
  var shouldShowSkeleton: Bool {
    switch store.selectDropDownItem {
    case .attandance:
      return store.attendanceCheck.loading
    case .schedule:
      return store.schedule.loading
    case .vote:
      return store.vote.loading
    }
  }

  @ViewBuilder
  var skeletonView: some View {
    switch store.selectDropDownItem {
    case .attandance:
      StaffSkeletonView()
    case .schedule:
      ScheduleSkeletonView()
    case .vote:
      VoteSkeletonView()
    }
  }
}
