//
//  StaffView.swift
//  DDDAttendance
//
//  Created by DDD on 6/6/24.
//

import DDDCoreUI
import DDDAccessibility
import SwiftUI

import DDDDesignKit

import ComposableArchitecture

public struct StaffView: View {
  @Bindable var store: StoreOf<StaffFeature>
  @State var isExpanded: Bool = false
  @State private var isDropDownClosing = false

  public init(store: StoreOf<StaffFeature>) {
    self.store = store
  }

  public var body: some View {
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
    .dddAccessibilityID(ManagementAccessibilityID.Staff.root)
    .overlay {
      dropDownView()
    }
    .overlay {
      dropDownInteractionBlocker
    }
    .overlay {
      if shouldShowSkeleton {
        skeletonView
          .transition(.opacity)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: store.viewState)
    .allowsHitTesting(!shouldShowSkeleton)
    .onTapGesture {
      if store.isExpandedDropDown {
        closeDropDown()
      }
    }
    .sheet(item: $store.scope(state: \.destination?.qrcode, action: \.destination.qrcode)) { qrCodeStore in
      QRScannerView(store: qrCodeStore)
      .presentationDetents([.height(UIScreen.screenHeight * 0.85)])
      .presentationCornerRadius(20)
      .presentationDragIndicator(.hidden)
    }
    // 투표 모달 — 전체 화면(상단바 포함)을 덮도록 루트에 부착
    .dddAlert($store.scope(state: \.vote.customAlert, action: \.vote.scope.customAlert))
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
          if store.isExpandedDropDown {
            closeDropDown()
          } else {
            openDropDown()
          }
        } label: {
          HStack {
            Text(store.selectDropDownItem.desc)
              .dddFont(.title2NormalBold)
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
        .dddAccessibilityID(ManagementAccessibilityID.Staff.sectionButton)

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
          .dddAccessibilityID(ManagementAccessibilityID.Staff.qrButton)

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
            store.send(.delegate(.presentManagerProfile))
          }
          .dddAccessibilityID(ManagementAccessibilityID.Staff.profileButton)
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
            closeDropDown()
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
              closeDropDown(.selectDropDownItem(matched))
            }
          }
        )
        .padding(.leading, 24)
        .padding(.top, 52)
      }
      .transition(.opacity)
      .zIndex(1)
    }
  }

  @ViewBuilder
  var dropDownInteractionBlocker: some View {
    if isDropDownClosing {
      Color.clear
        .contentShape(Rectangle())
        .ignoresSafeArea()
        .zIndex(2)
    }
  }
}

private extension StaffView {
  func openDropDown() {
    guard !isDropDownClosing else { return }
    withAnimation(.appQuick) {
      store.send(.view(.toggleDropDown))
    }
  }

  func closeDropDown(_ action: StaffFeature.View = .closeDropDown) {
    guard store.isExpandedDropDown, !isDropDownClosing else { return }
    isDropDownClosing = true

    withAnimation(.appQuick) {
      store.send(.view(action))
    } completion: {
      isDropDownClosing = false
    }
  }

  var shouldShowSkeleton: Bool {
    store.viewState == .loading
  }

  @ViewBuilder
  var skeletonView: some View {
    switch store.selectDropDownItem {
    case .attandance:
      StaffSkeletonView()
        .dddAccessibilityID(ManagementAccessibilityID.Staff.skeleton)
    case .schedule:
      ScheduleSkeletonView()
        .dddAccessibilityID(ManagementAccessibilityID.Staff.skeleton)
    case .vote:
      VoteSkeletonView()
        .dddAccessibilityID(ManagementAccessibilityID.Staff.skeleton)
    }
  }
}
