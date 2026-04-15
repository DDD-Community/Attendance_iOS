//
//  CustomModalModifier.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 1/15/26.
//

import SwiftUI

// Environment key for modal dismiss
public struct ModalDismissKey: EnvironmentKey {
  public static let defaultValue: (() -> Void) = { }
}

public extension EnvironmentValues {
  var modalDismiss: () -> Void {
    get { self[ModalDismissKey.self] }
    set { self[ModalDismissKey.self] = newValue }
  }
}

public enum ModalHeight {
  case fraction(CGFloat)
  case fixed(CGFloat)
  case auto
}

public struct CustomModalModifier<Item: Identifiable & Equatable, ModalContent: View>: ViewModifier {
  @Binding var item: Item?
  let height: ModalHeight
  let showDragIndicator: Bool
  let modalContent: (Item) -> ModalContent

  @State private var dragOffset: CGFloat = 0         // 드래그 오프셋
  @State private var dismissOffset: CGFloat = 0      // 닫기 오프셋
  @State private var isDragging: Bool = false        // 드래그 중 상태

  // MARK: - Animation Constants
  private let slideDistance: CGFloat = 400 // 부드러운 슬라이드 거리
  private let dismissThreshold: CGFloat = 100
  private let slideAnimation = Animation.easeInOut(duration: 0.3) // 단순한 슬라이드
  private let dragAnimation = Animation.linear(duration: 0.2) // 드래그도 단순하게

  public init(
    item: Binding<Item?>,
    height: ModalHeight = .auto,
    showDragIndicator: Bool = true,
    @ViewBuilder modalContent: @escaping (Item) -> ModalContent
  ) {
    self._item = item
    self.height = height
    self.showDragIndicator = showDragIndicator
    self.modalContent = modalContent
  }

  public func body(content: Content) -> some View {
    GeometryReader { geometry in
      content
        .overlay(
          Group {
            if item != nil {
              modalOverlay(geometry: geometry)
            }
          }
        )
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
  }

  // MARK: - Private Views
  @ViewBuilder
  private func modalOverlay(geometry: GeometryProxy) -> some View {
    ZStack {
      backgroundView
      modalContentView(geometry: geometry)
    }
  }

  private var backgroundView: some View {
    Color.black.opacity(0.4)
      .ignoresSafeArea()
      .ignoresSafeArea(.keyboard, edges: .bottom)
      .transition(.opacity.animation(.easeInOut(duration: 0.3)))
      .onTapGesture { dismissModal() }
  }

  @ViewBuilder
  private func modalContentView(geometry: GeometryProxy) -> some View {
    VStack(spacing: 0) {
      Spacer() // 상단 여백 유지

      if let currentItem = item {
        VStack(spacing: 0) {
          dragIndicatorView
          modalContent(currentItem)
            .frame(height: modalHeightValue(for: geometry))
            .environment(\.modalDismiss, dismissModal)
          bottomSpacer(geometry: geometry)
        }
        .background(.white)
        .clipShape(
          UnevenRoundedRectangle(
            topLeadingRadius: 30,
            bottomLeadingRadius: 30,
            bottomTrailingRadius: 30,
            topTrailingRadius: 30
          )
        )
        .offset(y: dragOffset + dismissOffset)
        .animation(isDragging ? nil : .easeOut(duration: 0.2), value: dragOffset)
        .onAppear {
          // 밑에서 올라오는 애니메이션
          dismissOffset = slideDistance
          withAnimation(.easeOut(duration: 0.4)) {
            dismissOffset = 0
          }
        }
        .onChange(of: item) { oldValue, newValue in
          // TCA에서 close 액션으로 destination이 nil이 되었을 때
          if oldValue != nil && newValue == nil {
            // 이미 애니메이션이 시작되지 않았다면 시작
            if dismissOffset == 0 {
              withAnimation(.easeOut(duration: 0.4)) {
                dismissOffset = slideDistance
              }
              dragOffset = 0
            }
          }
        }
        .gesture(dragGesture)
        .transition(.move(edge: .bottom))
        .animation(.easeOut(duration: 0.3), value: item != nil)
        .ignoresSafeArea(.keyboard, edges: .bottom)
      }
    }
  }

  @ViewBuilder
  private var dragIndicatorView: some View {
    if showDragIndicator {
      RoundedRectangle(cornerRadius: 2)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 36, height: 5)
        .padding(.top, 4)
    }
  }

  private func bottomSpacer(geometry: GeometryProxy) -> some View {
    Spacer()
      .frame(height: geometry.safeAreaInsets.bottom - 20)
  }

  // MARK: - Gesture
  private var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        isDragging = true
        // 아래로만 드래그 허용
        if value.translation.height > 0 {
          dragOffset = value.translation.height
        }
      }
      .onEnded { value in
        isDragging = false
        if value.translation.height > dismissThreshold {
          dismissModal() // 부드러운 닫기
        } else {
          // 원래 위치로 돌아가기
          withAnimation(.easeOut(duration: 0.2)) {
            dragOffset = 0
          }
        }
      }
  }

  // MARK: - Actions
  private func dismissModal() {
    withAnimation(.easeOut(duration: 0.3)) {
      dismissOffset = slideDistance
    }
    dragOffset = 0
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      item = nil
    }
  }

  // MARK: - Helper Methods
  private func modalHeightValue(for geometry: GeometryProxy) -> CGFloat? {
    let safeAreaBottom = geometry.safeAreaInsets.bottom
    let availableHeight = geometry.size.height - safeAreaBottom

    switch height {
      case .fraction(let fraction):
        return min(availableHeight * fraction, availableHeight)
      case .fixed(let points):
        return min(points, availableHeight)
      case .auto:
        return nil
    }
  }
}

public extension View {
  func presentDSModal<Item: Identifiable & Equatable, ModalContent: View>(
    item: Binding<Item?>,
    height: ModalHeight = .auto,
    showDragIndicator: Bool = true,
    @ViewBuilder content: @escaping (Item) -> ModalContent
  ) -> some View {
    modifier(
      CustomModalModifier(
        item: item,
        height: height,
        showDragIndicator: showDragIndicator,
        modalContent: content
      )
    )
  }
}