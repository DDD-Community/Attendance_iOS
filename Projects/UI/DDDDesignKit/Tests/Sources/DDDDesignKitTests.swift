import SwiftUI
import Testing
import UIKit
@testable import DDDDesignKit

private struct ModalItem: Identifiable, Equatable {
  let id: Int
}

@MainActor
@Suite("DDDDesignKit")
struct DDDDesignKitTests {
  @Test("타이포그래피의 모든 semantic case를 해석한다")
  func typographyTokens() {
    let tokens: [CustomSizeFont] = [
      .headline1Semibold, .headline2Semibold, .headline3Semibold,
      .headline4Semibold, .headline5Bold, .headline6NormalMedium,
      .headline6Bold, .headline7Medium, .headline7Semibold,
      .tilte1NormalBold, .tilte1NormalMedium, .title2NormalBold,
      .title2NormalMedium, .title3NormalBold, .title3NormalMedium,
      .title3NormalRegular, .body1NormalBold, .body1NormalMedium,
      .body1NormalRegular, .body2NormalBold, .body2NormalMedium,
      .body2NormalRegular, .body3NormalBold, .body3NormalMedium,
      .body3NormalRegular, .body4NormalRegular, .body4NormalMedium,
    ]

    for token in tokens {
      #expect(token.size > 0)
      _ = token.fontFamily
      render(Text("Typography").dddFont(token))
    }
  }

  @Test("버튼, 내비게이션, 툴팁 상태를 렌더링한다")
  func rendersButtonsAndNavigation() {
    let configs = [
      CustomButtonConfig.create(),
      CustomButtonConfig.createVoteButton(),
      CustomButtonConfig.createEndVoteButton(),
      CustomButtonConfig.createDateButton(),
    ]
    for config in configs {
      render(CustomButton(action: {}, title: "확인", config: config, isEnable: true))
      render(CustomButton(action: {}, title: "확인", config: config, isEnable: false))
    }

    render(NavigationBackButton(buttonAction: {}).buttonAction({}))
    render(StepNavigationBar(activeStep: 1, buttonAction: {}).activeStep(3).buttonAction({}))
    render(CustomNavigationBackBar(buttonAction: {}))
    render(
      CustomNavigationBar(backAction: {}, addAction: {}, image: .plus)
        .backAction({}).addAction({}).image(.danger)
    )
    render(TooltipShape(tooltipText: "안내").tooltipText("변경된 안내"))
    #expect(!TriangleDownShape().path(in: CGRect(x: 0, y: 0, width: 30, height: 20)).isEmpty)
  }

  @Test("칩과 피드백 입력의 선택 및 오류 상태를 렌더링한다")
  func rendersFeedbackComponents() {
    let items = [ChipItem(id: "1", title: "OT"), ChipItem(id: "2", title: "세션")]
    render(FeedbackChip(title: "OT", isSelected: true, action: {}))
    render(FeedbackChip(title: "세션", isSelected: false, action: {}).title("변경").isSelected(true).action({}))
    render(
      FeedbackChipGroup(
        items: items,
        selectedIDs: .constant(Set(["1"])),
        horizontalSpacing: 4,
        verticalSpacing: 6
      ).items(items).horizontalSpacing(8).verticalSpacing(8)
    )
    render(FeedbackYesNoQuestion(question: "참여할까요?", answer: .constant(.yes)).question("다시 참여할까요?"))
    render(FeedbackTextEditor(title: "의견", placeholder: "입력", text: .constant(""), minLength: 5))
    render(FeedbackTextEditor(title: "의견", titleStyle: .secondary, description: "설명", placeholder: "입력", text: .constant("짧음"), minLength: 5))
    render(FeedbackTextEditor(title: nil, placeholder: "입력", text: .constant(String(repeating: "가", count: 12)), maxLength: 10))
    render(StepProgressBar(currentStep: -1, totalSteps: 0).currentStep(2).totalSteps(3).animation(.linear))

    #expect(YesNoAnswer.yes.id == "yes")
    #expect(YesNoAnswer.yes.title == "예")
    #expect(YesNoAnswer.no.title == "아니오")
  }

  @Test("드롭다운의 열린 상태와 닫힌 상태를 렌더링한다")
  func rendersDropdowns() {
    let entries = [
      HomeDropdownMenu.Entry(id: "1", title: "출석", isSelected: true, showsNewBadge: true),
      HomeDropdownMenu.Entry(id: "2", title: "투표", isSelected: false),
    ]

    render(CustomDropdownMenu(isSelecting: .constant(true), selectionTitle: .constant("선택해주세요.")))
    render(CustomDropdownMenu(isSelecting: .constant(false), selectionTitle: .constant("이벤트 선택")))
    render(DropdownList(items: SelectDropDownItem.item, selectedItem: .constant(.attandance), isExpanded: .constant(true)).items(SelectDropDownItem.item))
    render(HomeDropdownMenu(entries: entries, onSelect: { _ in }).entries(entries).onSelect({ _ in }))

    for item in SelectDropDownItem.allCases {
      #expect(!item.desc.isEmpty)
    }
    #expect(solution([], _outlay: [], cash: 0) == 0)
  }

  @Test("alert factory와 모든 popup style을 렌더링한다")
  func rendersAlerts() {
    let alertItems = [
      AlertItem.withdrawAccount(onConfirm: {}, onCancel: {}),
      AlertItem.deleteData(dataName: "일정", onConfirm: {}, onCancel: {}),
      AlertItem.logout(onConfirm: {}, onCancel: {}),
      AlertItem.saveChanges(onConfirm: {}, onCancel: {}),
    ]
    for item in alertItems {
      render(Color.clear.dddConfirmationPopup(item: item))
    }
    render(Color.clear.dddConfirmationPopup(item: nil))
    render(Color.clear.dddConfirmationPopup(isPresented: true, title: "제목", message: "메시지", onConfirm: {}, onCancel: {}))
    render(Color.clear.dddConfirmationPopup(isPresented: false, title: "제목", message: "", onConfirm: {}, onCancel: {}))
    render(Color.clear.dddAlert(isPresented: true, title: "제목", message: "메시지", onConfirm: {}))

    let states: [CustomAlertState<CustomAlertAction>] = [
      .alert(title: "일반"), .withdrawAccount(), .exitWriting(), .startVote(),
      .endVote(), .logout(), .privacyPolicyConsent(),
      .appUpdate(version: "2.0", releaseNotes: "개선"),
      .appUpdate(version: "2.0", releaseNotes: nil),
      .appUpdate(version: "2.0", releaseNotes: ""),
    ]
    for state in states {
      render(
        CustomConfirmationPopup(
          title: state.title,
          message: state.message,
          confirmTitle: state.confirmTitle,
          cancelTitle: state.cancelTitle,
          isDestructive: state.isDestructive,
          style: state.style,
          checkboxTitle: state.checkboxTitle,
          onConfirm: {}, onCancel: {}, onPolicyTap: {}
        )
      )
    }
    #expect(states.count == 10)
  }

  @Test("modal 높이와 표시 상태를 렌더링한다")
  func rendersModals() {
    render(Color.clear.presentDSModal(item: .constant(ModalItem(id: 1)), height: .fraction(0.5)) { Text("fraction \($0.id)") })
    render(Color.clear.presentDSModal(item: .constant(ModalItem(id: 1)), height: .fixed(200), showDragIndicator: false) { Text("fixed \($0.id)") })
    render(Color.clear.presentDSModal(item: .constant(ModalItem(id: 1)), height: .auto) { Text("auto \($0.id)") })
    render(Color.clear.presentDSModal(item: .constant(nil as ModalItem?)) { Text("hidden \($0.id)") })
    ModalDismissKey.defaultValue()
  }

  @Test("toast의 모든 종류와 위치를 처리한다")
  func toastStates() async throws {
    let toasts: [ToastType] = [
      .success("성공"), .error("오류"), .warning("경고"), .info("정보"), .loading("로딩"),
    ]
    for toast in toasts {
      #expect(!toast.message.isEmpty)
      _ = toast.backgroundColor
      _ = toast.iconName
      _ = toast.iconColor
      render(ToastView(toast: toast).toast(toast))
    }
    render(Color.clear.dddToast(position: .top))
    render(Color.clear.dddToast(position: .bottom))

    let manager = ToastManager.shared
    manager.showSuccess("성공")
    manager.showError("오류")
    manager.showWarning("경고")
    manager.showInfo("정보")
    manager.showLoading("로딩")
    #expect(manager.isVisible)
    manager.hideToast()
    try await Task.sleep(for: .seconds(0.35))
    #expect(manager.currentToast == nil)
  }

  @Test("로딩 및 날짜 선택 UI를 렌더링한다")
  func rendersRemainingViews() {
    render(CustomPopUPDatePickerView(selectDate: .constant(Date())))
    render(LoadingView())
  }

  private func render<V: View>(_ view: V) {
    let controller = UIHostingController(rootView: view)
    controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    #expect(controller.view.bounds.height == 844)
  }
}
