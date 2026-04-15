//
//  AnimationTestView.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 1/15/26.
//

import SwiftUI

// MARK: - 테스트용 모달 아이템
public struct TestModalItem: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let message: String

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

// MARK: - 애니메이션 테스트 뷰
public struct AnimationTestView: View {
    @State private var modalItem: TestModalItem? = nil
    @State private var showConfirmation = false

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                toastSection
                modalSection
                alertSection
            }
            .padding()
        }
        .navigationTitle("애니메이션 테스트")
        // 고급 모달 적용
        .presentDSModal(
            item: $modalItem,
            height: .fraction(0.6),
            showDragIndicator: true
        ) { item in
            modalContent(item)
        }
        // 향상된 토스트 적용 (하단)
        .toastOverlay(
            position: .bottom,
            horizontalPadding: 20,
            bottomPadding: 100
        )
        // 확인 팝업 적용
        .customConfirmationPopup(
            isPresented: showConfirmation,
            title: "확인해주세요",
            message: "정말로 이 작업을 수행하시겠습니까?",
            confirmTitle: "확인",
            cancelTitle: "취소",
            onConfirm: {
                showConfirmation = false
                ToastManager.shared.showSuccess("작업이 완료되었습니다!")
            },
            onCancel: {
                showConfirmation = false
                ToastManager.shared.showInfo("작업이 취소되었습니다.")
            }
        )
    }
}

// MARK: - 섹션별 뷰
extension AnimationTestView {
    private var headerSection: some View {
        VStack {
            Text("🎭 TimeSpot 스타일 애니메이션")
                .font(.title2)
                .fontWeight(.bold)

            Text("고급 스프링 애니메이션과 드래그 제스처를 체험해보세요")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }

    private var toastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🍞 향상된 Toast")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                toastButton("성공", color: .green) {
                    ToastManager.shared.showSuccess("출석 체크가 완료되었습니다!")
                }

                toastButton("오류", color: .red) {
                    ToastManager.shared.showError("네트워크 오류가 발생했습니다.")
                }

                toastButton("경고", color: .orange) {
                    ToastManager.shared.showWarning("잠시 후 다시 시도해주세요.")
                }

                toastButton("정보", color: .blue) {
                    ToastManager.shared.showInfo("새로운 업데이트가 있습니다.")
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var modalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🪟 드래그 가능한 Modal")
                .font(.headline)

            VStack(spacing: 8) {
                modalTestButton("작은 모달 (40%)", height: .fraction(0.4)) {
                    TestModalItem(title: "작은 모달", message: "화면의 40% 크기입니다")
                }

                modalTestButton("중간 모달 (60%)", height: .fraction(0.6)) {
                    TestModalItem(title: "중간 모달", message: "아래로 드래그해서 닫을 수 있습니다")
                }

                modalTestButton("큰 모달 (88%)", height: .fraction(0.88)) {
                    TestModalItem(title: "큰 모달", message: "TimeSpot 스타일의 고급 모달입니다")
                }

                modalTestButton("고정 크기 모달", height: .fixed(400)) {
                    TestModalItem(title: "고정 크기", message: "400pt 고정 높이입니다")
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    private var alertSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🚨 확인 팝업")
                .font(.headline)

            Button("확인 팝업 열기") {
                showConfirmation = true
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.red.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Helper Views
extension AnimationTestView {
    private func toastButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(title) {
            action()
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(8)
    }

    private func modalTestButton(_ title: String, height: ModalHeight, itemGenerator: @escaping () -> TestModalItem) -> some View {
        Button(title) {
            modalItem = itemGenerator()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Color.blue.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(8)
    }

    private func modalContent(_ item: TestModalItem) -> some View {
        VStack(spacing: 20) {
            // 드래그 인디케이터는 자동으로 표시됨

            Text(item.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(item.message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Text("🎯 특징:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("• 아래로 드래그해서 닫기")
                Text("• 부드러운 스프링 애니메이션")
                Text("• 키보드 지원")
                Text("• 안전 영역 자동 처리")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Spacer()

            Button("닫기") {
                modalItem = nil
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        AnimationTestView()
    }
}