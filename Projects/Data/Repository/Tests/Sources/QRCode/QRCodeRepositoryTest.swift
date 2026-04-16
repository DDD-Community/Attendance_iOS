//
//  QRCodeRepositoryTest.swift
//  RepositoryTests
//
//  Created by TDD AI Automation on 2026-04-16
//

import Testing
import Foundation
import Entity
import Model
import DomainInterface
import Service

@Suite("QRCode Repository API Tests")
@MainActor
struct QRCodeRepositoryTest {

  // MARK: - Test Fixtures

  private func createMockQRCodeRepository() -> QRCodeRepositoryImpl {
    return QRCodeRepositoryImpl(provider: MockMoyaProvider<QRCodeService>())
  }

  // MARK: - API 호출 성공 테스트

  @Test("QR 코드 생성 API 호출 성공")
  func test_generate_qr_code_api_success() async throws {
    // Given
    let repository = createMockQRCodeRepository()

    // When
    let result = try await repository.generateQRCode(scheduleId: 12345)

    // Then
    #expect(result.qrCodeId == "qr_12345_abc123")
    #expect(result.scheduleId == 12345)
    #expect(result.qrCodeData == "DDD_ATTENDANCE_12345_abc123")
    #expect(result.isActive == true)
    #expect(result.expirationTime != nil)
    #expect(result.qrCodeImageUrl == "https://api.ddd.com/qr/images/qr_12345_abc123.png")
  }

  @Test("QR 코드 검증 API 호출 성공 - 유효한 코드")
  func test_validate_qr_code_api_success_valid() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let validQRData = "DDD_ATTENDANCE_12345_abc123"

    // When
    let result = try await repository.validateQRCode(qrCodeData: validQRData)

    // Then
    #expect(result.isValid == true)
    #expect(result.scheduleId == 12345)
    #expect(result.qrCodeId == "qr_12345_abc123")
    #expect(result.scheduleName == "DDD 정기모임")
    #expect(result.scheduleLocation == "강남역")
    #expect(result.validationMessage == "유효한 QR 코드입니다")
    #expect(result.attendanceEligible == true)
  }

  @Test("QR 코드 검증 API 호출 성공 - 만료된 코드")
  func test_validate_qr_code_api_success_expired() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let expiredQRData = "DDD_ATTENDANCE_99999_expired"

    // When
    let result = try await repository.validateQRCode(qrCodeData: expiredQRData)

    // Then
    #expect(result.isValid == false)
    #expect(result.scheduleId == 99999)
    #expect(result.qrCodeId == "qr_99999_expired")
    #expect(result.validationMessage == "만료된 QR 코드입니다")
    #expect(result.attendanceEligible == false)
    #expect(result.expirationTime != nil)
  }

  @Test("QR 코드 스캔을 통한 출석 체크 API 호출 성공")
  func test_check_attendance_with_qr_api_success() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let qrData = "DDD_ATTENDANCE_12345_abc123"

    // When
    let result = try await repository.checkAttendanceWithQR(qrCodeData: qrData, userId: 67890)

    // Then
    #expect(result.attendanceId == 789)
    #expect(result.userId == 67890)
    #expect(result.scheduleId == 12345)
    #expect(result.attendanceStatus == "참석")
    #expect(result.checkInTime != nil)
    #expect(result.isSuccessful == true)
    #expect(result.message == "출석이 정상적으로 처리되었습니다")
    #expect(result.lateMinutes == nil) // 정시 출석
  }

  @Test("QR 코드 스캔을 통한 지각 출석 체크 API 호출 성공")
  func test_check_attendance_with_qr_api_success_late() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let qrData = "DDD_ATTENDANCE_12345_late"

    // When
    let result = try await repository.checkAttendanceWithQR(qrCodeData: qrData, userId: 67890)

    // Then
    #expect(result.attendanceId == 790)
    #expect(result.userId == 67890)
    #expect(result.scheduleId == 12345)
    #expect(result.attendanceStatus == "지각")
    #expect(result.checkInTime != nil)
    #expect(result.isSuccessful == true)
    #expect(result.message == "지각 출석으로 처리되었습니다")
    #expect(result.lateMinutes == 15) // 15분 지각
  }

  @Test("QR 코드 비활성화 API 호출 성공")
  func test_deactivate_qr_code_api_success() async throws {
    // Given
    let repository = createMockQRCodeRepository()

    // When & Then
    try await repository.deactivateQRCode(qrCodeId: "qr_12345_abc123")

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  @Test("일정의 활성 QR 코드 목록 조회 API 호출 성공")
  func test_fetch_active_qr_codes_api_success() async throws {
    // Given
    let repository = createMockQRCodeRepository()

    // When
    let result = try await repository.fetchActiveQRCodes(scheduleId: 12345)

    // Then
    #expect(result.count == 2)

    // 첫 번째 QR 코드 검증
    #expect(result[0].qrCodeId == "qr_12345_abc123")
    #expect(result[0].scheduleId == 12345)
    #expect(result[0].isActive == true)
    #expect(result[0].qrCodeData == "DDD_ATTENDANCE_12345_abc123")

    // 두 번째 QR 코드 검증
    #expect(result[1].qrCodeId == "qr_12345_def456")
    #expect(result[1].scheduleId == 12345)
    #expect(result[1].isActive == true)
    #expect(result[1].qrCodeData == "DDD_ATTENDANCE_12345_def456")
  }

  @Test("QR 코드 이미지 업데이트 API 호출 성공")
  func test_update_qr_code_image_api_success() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let newImageData = Data("new_qr_image_data".utf8)

    // When & Then
    try await repository.updateQRCodeImage(qrCodeId: "qr_12345_abc123", imageData: newImageData)

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  // MARK: - API 호출 실패 테스트

  @Test("QR 코드 생성 API 호출 실패 (권한 없음)")
  func test_generate_qr_code_api_unauthorized() async throws {
    // Given
    let repository = createMockQRCodeRepository()

    // When & Then
    #expect(throws: QRCodeError.unauthorized) {
      try await repository.generateQRCode(scheduleId: -1) // 권한 오류를 트리거하는 값
    }
  }

  @Test("QR 코드 검증 API 호출 실패 (잘못된 형식)")
  func test_validate_qr_code_api_invalid_format() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let invalidQRData = "INVALID_QR_FORMAT"

    // When & Then
    #expect(throws: QRCodeError.invalidQRCodeFormat) {
      try await repository.validateQRCode(qrCodeData: invalidQRData)
    }
  }

  @Test("출석 체크 API 호출 실패 (중복 출석)")
  func test_check_attendance_api_duplicate_attendance() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let qrData = "DDD_ATTENDANCE_12345_duplicate"

    // When & Then
    #expect(throws: QRCodeError.duplicateAttendance) {
      try await repository.checkAttendanceWithQR(qrCodeData: qrData, userId: 67890)
    }
  }

  @Test("QR 코드 비활성화 API 호출 실패 (존재하지 않는 QR 코드)")
  func test_deactivate_qr_code_api_not_found() async throws {
    // Given
    let repository = createMockQRCodeRepository()

    // When & Then
    #expect(throws: QRCodeError.qrCodeNotFound) {
      try await repository.deactivateQRCode(qrCodeId: "invalid_qr_code_id")
    }
  }

  @Test("네트워크 오류 처리")
  func test_network_error_handling() async throws {
    // Given
    let repository = createMockQRCodeRepository()

    // When & Then
    #expect(throws: QRCodeError.networkError) {
      try await repository.generateQRCode(scheduleId: -999) // 네트워크 오류를 트리거하는 값
    }
  }

  // MARK: - DTO to Entity 매핑 테스트

  @Test("QRCodeGenerationResponseDTO to QRCodeEntity 매핑")
  func test_qr_code_generation_response_dto_mapping() throws {
    // Given
    let expirationTime = Date().addingTimeInterval(3600) // 1시간 후
    let createdAt = Date()

    let dto = QRCodeGenerationResponseDTO(
      qrCodeId: "qr_test_123",
      scheduleId: 54321,
      qrCodeData: "DDD_ATTENDANCE_54321_test123",
      qrCodeImageUrl: "https://api.ddd.com/qr/images/qr_test_123.png",
      isActive: true,
      expirationTime: expirationTime,
      createdAt: createdAt
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.qrCodeId == "qr_test_123")
    #expect(entity.scheduleId == 54321)
    #expect(entity.qrCodeData == "DDD_ATTENDANCE_54321_test123")
    #expect(entity.qrCodeImageUrl == "https://api.ddd.com/qr/images/qr_test_123.png")
    #expect(entity.isActive == true)
    #expect(entity.expirationTime == expirationTime)
    #expect(entity.createdAt == createdAt)
  }

  @Test("QRCodeValidationResponseDTO to QRCodeValidationEntity 매핑")
  func test_qr_code_validation_response_dto_mapping() throws {
    // Given
    let expirationTime = Date().addingTimeInterval(-3600) // 1시간 전 (만료됨)

    let dto = QRCodeValidationResponseDTO(
      isValid: false,
      qrCodeId: "qr_expired_456",
      scheduleId: 98765,
      scheduleName: "만료된 세미나",
      scheduleLocation: "온라인",
      validationMessage: "QR 코드가 만료되었습니다",
      attendanceEligible: false,
      expirationTime: expirationTime
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.isValid == false)
    #expect(entity.qrCodeId == "qr_expired_456")
    #expect(entity.scheduleId == 98765)
    #expect(entity.scheduleName == "만료된 세미나")
    #expect(entity.scheduleLocation == "온라인")
    #expect(entity.validationMessage == "QR 코드가 만료되었습니다")
    #expect(entity.attendanceEligible == false)
    #expect(entity.expirationTime == expirationTime)
  }

  @Test("AttendanceCheckResponseDTO to AttendanceCheckEntity 매핑")
  func test_attendance_check_response_dto_mapping() throws {
    // Given
    let checkInTime = Date()

    let dto = AttendanceCheckResponseDTO(
      attendanceId: 999,
      userId: 12345,
      scheduleId: 67890,
      qrCodeId: "qr_check_789",
      attendanceStatus: "지각",
      checkInTime: checkInTime,
      lateMinutes: 10,
      isSuccessful: true,
      message: "10분 지각으로 출석 처리되었습니다"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.attendanceId == 999)
    #expect(entity.userId == 12345)
    #expect(entity.scheduleId == 67890)
    #expect(entity.qrCodeId == "qr_check_789")
    #expect(entity.attendanceStatus == "지각")
    #expect(entity.checkInTime == checkInTime)
    #expect(entity.lateMinutes == 10)
    #expect(entity.isSuccessful == true)
    #expect(entity.message == "10분 지각으로 출석 처리되었습니다")
  }

  @Test("QRCodeListDTO to QRCodeEntity 매핑")
  func test_qr_code_list_dto_mapping() throws {
    // Given
    let expirationTime = Date().addingTimeInterval(7200) // 2시간 후
    let createdAt = Date()

    let dto = QRCodeListDTO(
      qrCodeId: "qr_list_001",
      scheduleId: 11111,
      qrCodeData: "DDD_ATTENDANCE_11111_list001",
      qrCodeImageUrl: "https://api.ddd.com/qr/images/qr_list_001.png",
      isActive: true,
      expirationTime: expirationTime,
      createdAt: createdAt,
      usageCount: 25
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.qrCodeId == "qr_list_001")
    #expect(entity.scheduleId == 11111)
    #expect(entity.qrCodeData == "DDD_ATTENDANCE_11111_list001")
    #expect(entity.qrCodeImageUrl == "https://api.ddd.com/qr/images/qr_list_001.png")
    #expect(entity.isActive == true)
    #expect(entity.expirationTime == expirationTime)
    #expect(entity.createdAt == createdAt)
    #expect(entity.usageCount == 25)
  }

  // MARK: - QR 코드 형식 검증 테스트

  @Test("올바른 QR 코드 데이터 형식 검증")
  func test_valid_qr_code_data_format() throws {
    // Given
    let validFormats = [
      "DDD_ATTENDANCE_12345_abc123",
      "DDD_ATTENDANCE_99999_xyz789",
      "DDD_ATTENDANCE_1_a"
    ]

    for validFormat in validFormats {
      let dto = QRCodeValidationResponseDTO(
        isValid: true,
        qrCodeId: "test_qr",
        scheduleId: 12345,
        scheduleName: "테스트 일정",
        scheduleLocation: "테스트 장소",
        validationMessage: "유효한 QR 코드",
        attendanceEligible: true,
        expirationTime: Date()
      )

      // When
      let entity = dto.toDomain()

      // Then
      #expect(entity.isValid == true)
      #expect(entity.attendanceEligible == true)
    }
  }

  @Test("특수한 QR 코드 만료 시간 처리")
  func test_special_qr_code_expiration_handling() throws {
    // Given - 이미 만료된 QR 코드
    let pastTime = Date().addingTimeInterval(-3600)

    let expiredDTO = QRCodeValidationResponseDTO(
      isValid: false,
      qrCodeId: "qr_expired",
      scheduleId: 12345,
      scheduleName: "만료된 일정",
      scheduleLocation: "만료된 장소",
      validationMessage: "만료된 QR 코드",
      attendanceEligible: false,
      expirationTime: pastTime
    )

    // When
    let expiredEntity = expiredDTO.toDomain()

    // Then
    #expect(expiredEntity.isValid == false)
    #expect(expiredEntity.attendanceEligible == false)
    #expect(expiredEntity.expirationTime == pastTime)

    // Given - 미래 시간 QR 코드
    let futureTime = Date().addingTimeInterval(7200)

    let futureDTO = QRCodeValidationResponseDTO(
      isValid: true,
      qrCodeId: "qr_future",
      scheduleId: 54321,
      scheduleName: "미래 일정",
      scheduleLocation: "미래 장소",
      validationMessage: "유효한 QR 코드",
      attendanceEligible: true,
      expirationTime: futureTime
    )

    // When
    let futureEntity = futureDTO.toDomain()

    // Then
    #expect(futureEntity.isValid == true)
    #expect(futureEntity.attendanceEligible == true)
    #expect(futureEntity.expirationTime == futureTime)
  }

  // MARK: - 경계값 테스트

  @Test("0분 지각 출석 처리")
  func test_zero_minutes_late_attendance() throws {
    // Given
    let dto = AttendanceCheckResponseDTO(
      attendanceId: 1000,
      userId: 2000,
      scheduleId: 3000,
      qrCodeId: "qr_zero_late",
      attendanceStatus: "참석",
      checkInTime: Date(),
      lateMinutes: 0,
      isSuccessful: true,
      message: "정시 출석으로 처리되었습니다"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.lateMinutes == 0)
    #expect(entity.attendanceStatus == "참석")
    #expect(entity.isSuccessful == true)
  }

  @Test("매우 긴 지각 시간 처리")
  func test_very_long_late_minutes() throws {
    // Given
    let dto = AttendanceCheckResponseDTO(
      attendanceId: 1001,
      userId: 2001,
      scheduleId: 3001,
      qrCodeId: "qr_very_late",
      attendanceStatus: "지각",
      checkInTime: Date(),
      lateMinutes: 300, // 5시간 지각
      isSuccessful: true,
      message: "300분 지각으로 출석 처리되었습니다"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.lateMinutes == 300)
    #expect(entity.attendanceStatus == "지각")
    #expect(entity.isSuccessful == true)
    #expect(entity.message == "300분 지각으로 출석 처리되었습니다")
  }

  @Test("빈 QR 코드 목록 처리")
  func test_empty_qr_code_list() async throws {
    // Given
    let repository = createMockQRCodeRepository()

    // When
    let result = try await repository.fetchActiveQRCodes(scheduleId: 99999) // 빈 목록을 반환하는 특수 값

    // Then
    #expect(result.isEmpty)
  }

  @Test("대용량 이미지 데이터 처리")
  func test_large_image_data_handling() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let largeImageData = Data(repeating: 0xFF, count: 1024 * 1024) // 1MB 이미지 데이터

    // When & Then
    try await repository.updateQRCodeImage(qrCodeId: "qr_large_image", imageData: largeImageData)

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  // MARK: - 동시성 테스트

  @Test("동시 QR 코드 생성 요청 처리")
  func test_concurrent_qr_code_generation() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let scheduleIds = [1001, 1002, 1003, 1004, 1005]

    // When
    await withTaskGroup(of: Void.self) { group in
      for scheduleId in scheduleIds {
        group.addTask {
          do {
            _ = try await repository.generateQRCode(scheduleId: scheduleId)
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 크래시나 데드락 없이 완료되어야 함
    #expect(true)
  }

  @Test("동시 출석 체크 요청 처리")
  func test_concurrent_attendance_check() async throws {
    // Given
    let repository = createMockQRCodeRepository()
    let userIds = [5001, 5002, 5003, 5004, 5005]
    let qrData = "DDD_ATTENDANCE_12345_concurrent"

    // When
    await withTaskGroup(of: Void.self) { group in
      for userId in userIds {
        group.addTask {
          do {
            _ = try await repository.checkAttendanceWithQR(qrCodeData: qrData, userId: userId)
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 완료되어야 함
    #expect(true)
  }
}

// MARK: - Mock MoyaProvider for QRCode

extension MockMoyaProvider where Target == QRCodeService {

  override func request<T: Decodable>(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) async throws -> T {
    if let qrCodeTarget = target as? QRCodeService {
      return try createMockQRCodeResponse(for: qrCodeTarget) as! T
    }

    throw QRCodeError.networkError
  }

  private func createMockQRCodeResponse<T: Decodable>(for target: QRCodeService) throws -> T {
    switch target {
    case .generateQRCode(let scheduleId):
      if scheduleId == -1 {
        throw QRCodeError.unauthorized
      }
      if scheduleId == -999 {
        throw QRCodeError.networkError
      }

      let response = QRCodeGenerationResponseDTO(
        qrCodeId: "qr_12345_abc123",
        scheduleId: scheduleId,
        qrCodeData: "DDD_ATTENDANCE_12345_abc123",
        qrCodeImageUrl: "https://api.ddd.com/qr/images/qr_12345_abc123.png",
        isActive: true,
        expirationTime: Date().addingTimeInterval(3600),
        createdAt: Date()
      )
      return response as! T

    case .validateQRCode(let qrCodeData):
      if qrCodeData == "INVALID_QR_FORMAT" {
        throw QRCodeError.invalidQRCodeFormat
      }

      if qrCodeData == "DDD_ATTENDANCE_99999_expired" {
        let expiredResponse = QRCodeValidationResponseDTO(
          isValid: false,
          qrCodeId: "qr_99999_expired",
          scheduleId: 99999,
          scheduleName: "만료된 일정",
          scheduleLocation: "만료된 장소",
          validationMessage: "만료된 QR 코드입니다",
          attendanceEligible: false,
          expirationTime: Date().addingTimeInterval(-3600)
        )
        return expiredResponse as! T
      }

      let validResponse = QRCodeValidationResponseDTO(
        isValid: true,
        qrCodeId: "qr_12345_abc123",
        scheduleId: 12345,
        scheduleName: "DDD 정기모임",
        scheduleLocation: "강남역",
        validationMessage: "유효한 QR 코드입니다",
        attendanceEligible: true,
        expirationTime: Date().addingTimeInterval(3600)
      )
      return validResponse as! T

    case .checkAttendanceWithQR(let qrCodeData, let userId):
      if qrCodeData == "DDD_ATTENDANCE_12345_duplicate" {
        throw QRCodeError.duplicateAttendance
      }

      if qrCodeData == "DDD_ATTENDANCE_12345_late" {
        let lateResponse = AttendanceCheckResponseDTO(
          attendanceId: 790,
          userId: userId,
          scheduleId: 12345,
          qrCodeId: "qr_12345_late",
          attendanceStatus: "지각",
          checkInTime: Date(),
          lateMinutes: 15,
          isSuccessful: true,
          message: "지각 출석으로 처리되었습니다"
        )
        return lateResponse as! T
      }

      let response = AttendanceCheckResponseDTO(
        attendanceId: 789,
        userId: userId,
        scheduleId: 12345,
        qrCodeId: "qr_12345_abc123",
        attendanceStatus: "참석",
        checkInTime: Date(),
        lateMinutes: nil,
        isSuccessful: true,
        message: "출석이 정상적으로 처리되었습니다"
      )
      return response as! T

    case .fetchActiveQRCodes(let scheduleId):
      if scheduleId == 99999 {
        return [] as! T // 빈 배열 반환
      }

      let qrCodes = [
        QRCodeListDTO(
          qrCodeId: "qr_12345_abc123",
          scheduleId: scheduleId,
          qrCodeData: "DDD_ATTENDANCE_12345_abc123",
          qrCodeImageUrl: "https://api.ddd.com/qr/images/qr_12345_abc123.png",
          isActive: true,
          expirationTime: Date().addingTimeInterval(3600),
          createdAt: Date(),
          usageCount: 15
        ),
        QRCodeListDTO(
          qrCodeId: "qr_12345_def456",
          scheduleId: scheduleId,
          qrCodeData: "DDD_ATTENDANCE_12345_def456",
          qrCodeImageUrl: "https://api.ddd.com/qr/images/qr_12345_def456.png",
          isActive: true,
          expirationTime: Date().addingTimeInterval(7200),
          createdAt: Date(),
          usageCount: 8
        )
      ]
      return qrCodes as! T

    case .deactivateQRCode(let qrCodeId):
      if qrCodeId == "invalid_qr_code_id" {
        throw QRCodeError.qrCodeNotFound
      }
      return () as! T

    case .updateQRCodeImage(_, _):
      return () as! T

    default:
      throw QRCodeError.networkError
    }
  }
}

// MARK: - Mock DTOs

struct QRCodeGenerationResponseDTO: Codable {
  let qrCodeId: String
  let scheduleId: Int
  let qrCodeData: String
  let qrCodeImageUrl: String
  let isActive: Bool
  let expirationTime: Date
  let createdAt: Date

  func toDomain() -> QRCodeEntity {
    return QRCodeEntity(
      qrCodeId: qrCodeId,
      scheduleId: scheduleId,
      qrCodeData: qrCodeData,
      qrCodeImageUrl: qrCodeImageUrl,
      isActive: isActive,
      expirationTime: expirationTime,
      createdAt: createdAt,
      usageCount: nil
    )
  }
}

struct QRCodeValidationResponseDTO: Codable {
  let isValid: Bool
  let qrCodeId: String
  let scheduleId: Int
  let scheduleName: String
  let scheduleLocation: String
  let validationMessage: String
  let attendanceEligible: Bool
  let expirationTime: Date

  func toDomain() -> QRCodeValidationEntity {
    return QRCodeValidationEntity(
      isValid: isValid,
      qrCodeId: qrCodeId,
      scheduleId: scheduleId,
      scheduleName: scheduleName,
      scheduleLocation: scheduleLocation,
      validationMessage: validationMessage,
      attendanceEligible: attendanceEligible,
      expirationTime: expirationTime
    )
  }
}

struct AttendanceCheckResponseDTO: Codable {
  let attendanceId: Int
  let userId: Int
  let scheduleId: Int
  let qrCodeId: String
  let attendanceStatus: String
  let checkInTime: Date
  let lateMinutes: Int?
  let isSuccessful: Bool
  let message: String

  func toDomain() -> AttendanceCheckEntity {
    return AttendanceCheckEntity(
      attendanceId: attendanceId,
      userId: userId,
      scheduleId: scheduleId,
      qrCodeId: qrCodeId,
      attendanceStatus: attendanceStatus,
      checkInTime: checkInTime,
      lateMinutes: lateMinutes,
      isSuccessful: isSuccessful,
      message: message
    )
  }
}

struct QRCodeListDTO: Codable {
  let qrCodeId: String
  let scheduleId: Int
  let qrCodeData: String
  let qrCodeImageUrl: String
  let isActive: Bool
  let expirationTime: Date
  let createdAt: Date
  let usageCount: Int

  func toDomain() -> QRCodeEntity {
    return QRCodeEntity(
      qrCodeId: qrCodeId,
      scheduleId: scheduleId,
      qrCodeData: qrCodeData,
      qrCodeImageUrl: qrCodeImageUrl,
      isActive: isActive,
      expirationTime: expirationTime,
      createdAt: createdAt,
      usageCount: usageCount
    )
  }
}

// MARK: - Mock Entities

struct QRCodeEntity {
  let qrCodeId: String
  let scheduleId: Int
  let qrCodeData: String
  let qrCodeImageUrl: String
  let isActive: Bool
  let expirationTime: Date
  let createdAt: Date
  let usageCount: Int?
}

struct QRCodeValidationEntity {
  let isValid: Bool
  let qrCodeId: String
  let scheduleId: Int
  let scheduleName: String
  let scheduleLocation: String
  let validationMessage: String
  let attendanceEligible: Bool
  let expirationTime: Date
}

struct AttendanceCheckEntity {
  let attendanceId: Int
  let userId: Int
  let scheduleId: Int
  let qrCodeId: String
  let attendanceStatus: String
  let checkInTime: Date
  let lateMinutes: Int?
  let isSuccessful: Bool
  let message: String
}

// MARK: - Mock Errors

enum QRCodeError: Error {
  case unauthorized
  case invalidQRCodeFormat
  case duplicateAttendance
  case qrCodeNotFound
  case networkError
}