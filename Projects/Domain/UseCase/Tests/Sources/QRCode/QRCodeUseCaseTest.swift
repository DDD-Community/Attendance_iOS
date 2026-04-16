//
//  QRCodeUseCaseTest.swift
//  UseCaseTests
//
//  Created by TDD AI Automation on 2026-04-16
//

import Testing
import Foundation
import SwiftUI
import ComposableArchitecture
@testable import UseCase
@testable import Entity
@testable import DomainInterface

@Suite("QRCode UseCase Tests - Complete TDD Implementation", .tags(.unit, .qrcode))
@MainActor
struct QRCodeUseCaseTest {

    // MARK: - Test Dependencies
    private var mockQRCodeRepository: MockQRCodeRepository!

    init() async {
        mockQRCodeRepository = MockQRCodeRepository()
    }

    // MARK: - Core QRCode Tests (13 Test Cases)

    @Test("TC-001: QR 코드 생성 성공")
    func test_create_qr_code_success() async throws {
        // Given: 사용자 ID로 QR 코드 생성 설정
        let userID = 123
        let expectedQRString = "qr_code_data_for_user_123"
        mockQRCodeRepository.configureCreateQRSuccess(expectedQRString)

        // When: QR 코드 생성 실행
        let result = try await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return try await useCase.createQRCode(userID: userID)
        }

        // Then: QR 코드 생성 검증
        #expect(result == expectedQRString, "올바른 QR 코드 문자열이 생성되어야 함")
        #expect(mockQRCodeRepository.lastCreateQRUserID == userID, "올바른 사용자 ID가 전달되어야 함")
        #expect(mockQRCodeRepository.createQRCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-002: QR 코드 생성 실패 (잘못된 사용자 ID)")
    func test_create_qr_code_invalid_user_id() async throws {
        // Given: 잘못된 사용자 ID 에러 설정
        mockQRCodeRepository.configureCreateQRFailure(QRCodeError.invalidUserID)

        // When & Then: 잘못된 사용자 ID 에러 검증
        await #expect(throws: QRCodeError.self) {
            try await withDependencies {
                $0.qrCodeRepository = mockQRCodeRepository
            } operation: {
                let useCase = QRCodeUseCaseImpl()
                _ = try await useCase.createQRCode(userID: -1) // 잘못된 ID
            }
        }

        #expect(mockQRCodeRepository.createQRCallCount == 1, "실패해도 Repository는 호출되어야 함")
    }

    @Test("TC-003: QR 이미지 생성 성공")
    func test_generate_qr_image_success() async {
        // Given: QR 문자열로 이미지 생성 설정
        let qrString = "test_qr_data_123"
        let expectedImage = Image(systemName: "qrcode")
        mockQRCodeRepository.configureGenerateQRSuccess(expectedImage)

        // When: QR 이미지 생성 실행
        let result = await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return await useCase.generateQRCode(from: qrString)
        }

        // Then: QR 이미지 생성 검증
        #expect(result != nil, "QR 이미지가 생성되어야 함")
        #expect(mockQRCodeRepository.lastGenerateQRString == qrString, "올바른 QR 문자열이 전달되어야 함")
        #expect(mockQRCodeRepository.generateQRCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-004: QR 이미지 생성 실패 (빈 문자열)")
    func test_generate_qr_image_empty_string() async {
        // Given: 빈 문자열로 이미지 생성 설정 (nil 반환)
        mockQRCodeRepository.configureGenerateQRSuccess(nil)

        // When: 빈 문자열로 QR 이미지 생성 실행
        let result = await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return await useCase.generateQRCode(from: "")
        }

        // Then: QR 이미지 생성 실패 검증
        #expect(result == nil, "빈 문자열로는 QR 이미지가 생성되지 않아야 함")
        #expect(mockQRCodeRepository.lastGenerateQRString == "", "빈 문자열이 전달되어야 함")
    }

    @Test("TC-005: QR 검증 성공 (출석 체크)")
    func test_qr_validate_success_attendance() async throws {
        // Given: 성공적인 QR 검증 설정
        let qrCode = "valid_qr_code_123"
        let expectedValidation = QRValidateEntity(
            isSuccess: true,
            code: "200",
            message: "출석 체크가 완료되었습니다",
            detail: "정상적으로 출석 처리되었습니다",
            status: .attendance
        )
        mockQRCodeRepository.configureValidateSuccess(expectedValidation)

        // When: QR 검증 실행
        let result = try await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return try await useCase.qrValidateCheck(from: qrCode)
        }

        // Then: QR 검증 성공 검증
        #expect(result.isSuccess, "QR 검증이 성공해야 함")
        #expect(result.message == "출석 체크가 완료되었습니다", "성공 메시지가 올바르게 반환되어야 함")
        #expect(result.status == .attendance, "출석 상태가 올바르게 설정되어야 함")
        #expect(mockQRCodeRepository.lastValidateQRCode == qrCode, "올바른 QR 코드가 전달되어야 함")
        #expect(mockQRCodeRepository.validateCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-006: QR 검증 성공 (지각 체크)")
    func test_qr_validate_success_late() async throws {
        // Given: 지각 상태 QR 검증 설정
        let qrCode = "valid_qr_code_late"
        let expectedValidation = QRValidateEntity(
            isSuccess: true,
            code: "201",
            message: "지각 체크가 완료되었습니다",
            detail: "지각으로 처리되었습니다",
            status: .late
        )
        mockQRCodeRepository.configureValidateSuccess(expectedValidation)

        // When: QR 검증 실행
        let result = try await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return try await useCase.qrValidateCheck(from: qrCode)
        }

        // Then: QR 검증 지각 검증
        #expect(result.isSuccess, "QR 검증이 성공해야 함")
        #expect(result.status == .late, "지각 상태가 올바르게 설정되어야 함")
        #expect(result.message?.contains("지각") == true, "지각 관련 메시지가 포함되어야 함")
    }

    @Test("TC-007: QR 검증 실패 (잘못된 QR 코드)")
    func test_qr_validate_failure_invalid_code() async throws {
        // Given: 잘못된 QR 코드 검증 설정
        let invalidQRCode = "invalid_qr_code"
        let expectedValidation = QRValidateEntity(
            isSuccess: false,
            code: "400",
            message: "잘못된 QR 코드입니다",
            detail: "QR 코드를 다시 확인해주세요",
            status: nil
        )
        mockQRCodeRepository.configureValidateSuccess(expectedValidation)

        // When: 잘못된 QR 검증 실행
        let result = try await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return try await useCase.qrValidateCheck(from: invalidQRCode)
        }

        // Then: QR 검증 실패 검증
        #expect(!result.isSuccess, "QR 검증이 실패해야 함")
        #expect(result.message == "잘못된 QR 코드입니다", "실패 메시지가 올바르게 반환되어야 함")
        #expect(result.status == nil, "실패 시 상태는 nil이어야 함")
        #expect(result.code == "400", "오류 코드가 올바르게 설정되어야 함")
    }

    @Test("TC-008: QR 검증 실패 (만료된 QR 코드)")
    func test_qr_validate_failure_expired_code() async throws {
        // Given: 만료된 QR 코드 에러 설정
        mockQRCodeRepository.configureValidateFailure(QRCodeError.expiredQRCode)

        // When & Then: 만료된 QR 코드 에러 검증
        await #expect(throws: QRCodeError.self) {
            try await withDependencies {
                $0.qrCodeRepository = mockQRCodeRepository
            } operation: {
                let useCase = QRCodeUseCaseImpl()
                _ = try await useCase.qrValidateCheck(from: "expired_qr_code")
            }
        }
    }

    @Test("TC-009: QR 검증 실패 (중복 체크)")
    func test_qr_validate_failure_duplicate_check() async throws {
        // Given: 중복 체크 실패 설정
        let duplicateQRCode = "already_checked_qr"
        let expectedValidation = QRValidateEntity(
            isSuccess: false,
            code: "409",
            message: "이미 출석 체크가 완료되었습니다",
            detail: "중복 출석 체크는 불가능합니다",
            status: .attendance // 이미 체크된 상태
        )
        mockQRCodeRepository.configureValidateSuccess(expectedValidation)

        // When: 중복 QR 검증 실행
        let result = try await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return try await useCase.qrValidateCheck(from: duplicateQRCode)
        }

        // Then: 중복 체크 실패 검증
        #expect(!result.isSuccess, "중복 체크는 실패해야 함")
        #expect(result.code == "409", "중복 에러 코드가 반환되어야 함")
        #expect(result.message?.contains("중복") == true, "중복 관련 메시지가 포함되어야 함")
    }

    @Test("TC-010: 복잡한 QR 데이터 처리")
    func test_complex_qr_data_handling() async throws {
        // Given: 복잡한 QR 데이터 설정
        let complexUserID = 999999
        let expectedComplexQR = "user:999999;timestamp:1713194400;event:attendance;signature:abc123def456"
        mockQRCodeRepository.configureCreateQRSuccess(expectedComplexQR)

        // When: 복잡한 QR 코드 생성 실행
        let result = try await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return try await useCase.createQRCode(userID: complexUserID)
        }

        // Then: 복잡한 QR 데이터 검증
        #expect(result.contains("user:999999"), "사용자 ID가 포함되어야 함")
        #expect(result.contains("timestamp:"), "타임스탬프가 포함되어야 함")
        #expect(result.contains("event:attendance"), "이벤트 타입이 포함되어야 함")
        #expect(result.contains("signature:"), "서명이 포함되어야 함")
        #expect(result == expectedComplexQR, "전체 QR 데이터가 일치해야 함")
    }

    @Test("TC-011: QR 코드 전체 플로우 테스트")
    func test_qr_code_full_flow() async throws {
        // Given: QR 전체 플로우 설정 (생성 → 이미지 생성 → 검증)
        let userID = 456
        let qrString = "flow_test_qr_456"
        let qrImage = Image(systemName: "checkmark.circle")
        let validation = QRValidateEntity(
            isSuccess: true,
            code: "200",
            message: "플로우 테스트 성공",
            detail: "전체 플로우가 정상적으로 동작했습니다",
            status: .attendance
        )

        mockQRCodeRepository.configureCreateQRSuccess(qrString)
        mockQRCodeRepository.configureGenerateQRSuccess(qrImage)
        mockQRCodeRepository.configureValidateSuccess(validation)

        // When: QR 전체 플로우 실행
        let createdQR = try await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return try await useCase.createQRCode(userID: userID)
        }

        let generatedImage = await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return await useCase.generateQRCode(from: createdQR)
        }

        let validationResult = try await withDependencies {
            $0.qrCodeRepository = mockQRCodeRepository
        } operation: {
            let useCase = QRCodeUseCaseImpl()
            return try await useCase.qrValidateCheck(from: createdQR)
        }

        // Then: 전체 플로우 검증
        #expect(createdQR == qrString, "QR 코드가 정상 생성되어야 함")
        #expect(generatedImage != nil, "QR 이미지가 정상 생성되어야 함")
        #expect(validationResult.isSuccess, "QR 검증이 성공해야 함")
        #expect(validationResult.status == .attendance, "출석 상태가 정상 설정되어야 함")

        // Repository 호출 횟수 검증
        #expect(mockQRCodeRepository.createQRCallCount == 1, "QR 생성이 1번 호출되어야 함")
        #expect(mockQRCodeRepository.generateQRCallCount == 1, "이미지 생성이 1번 호출되어야 함")
        #expect(mockQRCodeRepository.validateCallCount == 1, "검증이 1번 호출되어야 함")
    }

    @Test("TC-012: 동시 QR 검증 요청 처리")
    func test_concurrent_qr_validation_requests() async throws {
        // Given: 동시 검증 요청을 위한 설정
        let concurrentQRCodes = [
            "concurrent_qr_1",
            "concurrent_qr_2",
            "concurrent_qr_3",
            "concurrent_qr_4",
            "concurrent_qr_5"
        ]

        let validationResults = concurrentQRCodes.map { qr in
            QRValidateEntity(
                isSuccess: true,
                code: "200",
                message: "\(qr) 검증 성공",
                detail: "동시 요청 테스트 성공",
                status: .attendance
            )
        }

        mockQRCodeRepository.configureConcurrentValidateSuccess(validationResults)

        // When: 5개의 동시 QR 검증 요청 실행
        let results = try await withTaskGroup(of: QRValidateEntity.self, returning: [QRValidateEntity].self) { group in
            for qrCode in concurrentQRCodes {
                group.addTask {
                    try await withDependencies {
                        $0.qrCodeRepository = mockQRCodeRepository
                    } operation: {
                        let useCase = QRCodeUseCaseImpl()
                        return try await useCase.qrValidateCheck(from: qrCode)
                    }
                }
            }

            var results: [QRValidateEntity] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }

        // Then: 동시 요청 결과 검증
        #expect(results.count == 5, "모든 동시 요청이 처리되어야 함")
        #expect(results.allSatisfy(\.isSuccess), "모든 요청이 성공해야 함")
        #expect(results.allSatisfy { $0.status == .attendance }, "모든 결과가 출석 상태여야 함")
        #expect(mockQRCodeRepository.validateCallCount == 5, "Repository가 5번 호출되어야 함")
    }

    @Test("TC-013: QR 데이터 경계값 테스트")
    func test_qr_data_boundary_values() async throws {
        // Given: 경계값 테스트 데이터
        let boundaryUserIDs = [0, 1, Int.max, -1]
        let expectedResults = [
            "qr_user_0",
            "qr_user_1",
            "qr_user_max",
            "qr_user_negative"
        ]

        // When & Then: 각 경계값에 대해 테스트
        for (index, userID) in boundaryUserIDs.enumerated() {
            mockQRCodeRepository.configureCreateQRSuccess(expectedResults[index])

            let result = try await withDependencies {
                $0.qrCodeRepository = mockQRCodeRepository
            } operation: {
                let useCase = QRCodeUseCaseImpl()
                return try await useCase.createQRCode(userID: userID)
            }

            #expect(result == expectedResults[index], "경계값 \(userID)에 대한 QR이 올바르게 생성되어야 함")
        }

        #expect(mockQRCodeRepository.createQRCallCount == 4, "모든 경계값 테스트가 실행되어야 함")
    }
}

// MARK: - Mock Repository
class MockQRCodeRepository: QRCodeInterface {

    // MARK: - Call Tracking
    var createQRCallCount = 0
    var generateQRCallCount = 0
    var validateCallCount = 0

    // MARK: - Last Parameters
    var lastCreateQRUserID: Int?
    var lastGenerateQRString: String?
    var lastValidateQRCode: String?

    // MARK: - Configured Responses
    private var createQRResponse: Result<String, Error>?
    private var generateQRResponse: Image?
    private var validateResponse: Result<QRValidateEntity, Error>?
    private var concurrentValidateIndex = 0
    private var concurrentValidateResults: [QRValidateEntity] = []

    // MARK: - Implementation
    func createQRCode(userID: Int) async throws -> String {
        createQRCallCount += 1
        lastCreateQRUserID = userID

        if let response = createQRResponse {
            return try response.get()
        }

        throw QRCodeError.notConfigured
    }

    func generateQRCode(from string: String) async -> Image? {
        generateQRCallCount += 1
        lastGenerateQRString = string

        return generateQRResponse
    }

    func qrValidateCheck(from code: String) async throws -> QRValidateEntity {
        validateCallCount += 1
        lastValidateQRCode = code

        // 동시 요청 처리
        if !concurrentValidateResults.isEmpty && concurrentValidateIndex < concurrentValidateResults.count {
            let result = concurrentValidateResults[concurrentValidateIndex]
            concurrentValidateIndex += 1
            return result
        }

        if let response = validateResponse {
            return try response.get()
        }

        throw QRCodeError.notConfigured
    }

    // MARK: - Configuration Methods
    func configureCreateQRSuccess(_ qrString: String) {
        createQRResponse = .success(qrString)
    }

    func configureCreateQRFailure(_ error: Error) {
        createQRResponse = .failure(error)
    }

    func configureGenerateQRSuccess(_ image: Image?) {
        generateQRResponse = image
    }

    func configureValidateSuccess(_ validation: QRValidateEntity) {
        validateResponse = .success(validation)
    }

    func configureValidateFailure(_ error: Error) {
        validateResponse = .failure(error)
    }

    func configureConcurrentValidateSuccess(_ validations: [QRValidateEntity]) {
        concurrentValidateResults = validations
        concurrentValidateIndex = 0
    }
}

// MARK: - Test Errors
enum QRCodeError: Error, Equatable {
    case invalidUserID
    case expiredQRCode
    case duplicateCheck
    case networkError
    case notConfigured
}

// MARK: - Test Tags
extension Tag {
    @Tag static var unit: Self
    @Tag static var qrcode: Self
}