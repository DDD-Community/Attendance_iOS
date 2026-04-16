//
//  OnBoardingRepositoryTest.swift
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

@Suite("OnBoarding Repository API Tests")
@MainActor
struct OnBoardingRepositoryTest {

  // MARK: - Test Fixtures

  private func createMockOnBoardingRepository() -> OnBoardingRepositoryImpl {
    return OnBoardingRepositoryImpl(provider: MockMoyaProvider<OnBoardingService>())
  }

  // MARK: - API 호출 성공 테스트

  @Test("초대 코드 검증 API 호출 성공 - 유효한 코드")
  func test_validate_invite_code_api_success_valid() async throws {
    // Given
    let repository = createMockOnBoardingRepository()
    let validInviteCode = "DDD2025INVITE"

    // When
    let result = try await repository.validateInviteCode(inviteCode: validInviteCode)

    // Then
    #expect(result.isValid == true)
    #expect(result.inviteCode == "DDD2025INVITE")
    #expect(result.organizationName == "DDD Community")
    #expect(result.generation == "10기")
    #expect(result.availableTeams.count == 4)
    #expect(result.availableTeams.contains("iOS"))
    #expect(result.availableTeams.contains("Android"))
    #expect(result.availableTeams.contains("웹"))
    #expect(result.availableTeams.contains("백엔드"))
    #expect(result.maxMembers == 30)
    #expect(result.currentMembers == 15)
    #expect(result.message == "유효한 초대 코드입니다")
  }

  @Test("초대 코드 검증 API 호출 성공 - 만료된 코드")
  func test_validate_invite_code_api_success_expired() async throws {
    // Given
    let repository = createMockOnBoardingRepository()
    let expiredInviteCode = "DDD2024EXPIRED"

    // When
    let result = try await repository.validateInviteCode(inviteCode: expiredInviteCode)

    // Then
    #expect(result.isValid == false)
    #expect(result.inviteCode == "DDD2024EXPIRED")
    #expect(result.organizationName == "DDD Community")
    #expect(result.generation == "9기")
    #expect(result.message == "만료된 초대 코드입니다")
    #expect(result.expiredAt != nil)
  }

  @Test("팀 목록 조회 API 호출 성공")
  func test_fetch_available_teams_api_success() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When
    let result = try await repository.fetchAvailableTeams()

    // Then
    #expect(result.count == 5)

    // iOS 팀 검증
    #expect(result[0].teamId == 1)
    #expect(result[0].teamName == "iOS")
    #expect(result[0].description == "iOS 앱 개발")
    #expect(result[0].maxMembers == 8)
    #expect(result[0].currentMembers == 6)
    #expect(result[0].isAvailable == true)

    // Android 팀 검증
    #expect(result[1].teamId == 2)
    #expect(result[1].teamName == "Android")
    #expect(result[1].description == "Android 앱 개발")
    #expect(result[1].maxMembers == 8)
    #expect(result[1].currentMembers == 5)
    #expect(result[1].isAvailable == true)

    // 백엔드 팀 검증 (정원 초과)
    #expect(result[4].teamId == 5)
    #expect(result[4].teamName == "백엔드")
    #expect(result[4].maxMembers == 6)
    #expect(result[4].currentMembers == 6)
    #expect(result[4].isAvailable == false)
  }

  @Test("직무 목록 조회 API 호출 성공")
  func test_fetch_available_parts_api_success() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When
    let result = try await repository.fetchAvailableParts()

    // Then
    #expect(result.count == 6)

    // iOS 개발자 검증
    #expect(result[0].partId == 1)
    #expect(result[0].partName == "iOS 개발자")
    #expect(result[0].description == "iOS 네이티브 앱 개발")
    #expect(result[0].requiredSkills == ["Swift", "SwiftUI", "UIKit"])
    #expect(result[0].preferredTeams == ["iOS"])

    // 풀스택 개발자 검증
    #expect(result[5].partId == 6)
    #expect(result[5].partName == "풀스택 개발자")
    #expect(result[5].description == "프론트엔드 + 백엔드 개발")
    #expect(result[5].requiredSkills == ["JavaScript", "TypeScript", "React", "Node.js"])
    #expect(result[5].preferredTeams == ["웹", "백엔드"])
  }

  @Test("온보딩 완료 API 호출 성공")
  func test_complete_onboarding_api_success() async throws {
    // Given
    let repository = createMockOnBoardingRepository()
    let onboardingRequest = CompleteOnboardingRequest(
      inviteCode: "DDD2025INVITE",
      selectedTeamId: 1,
      selectedPartId: 1,
      introduction: "안녕하세요! iOS 개발에 열정이 있는 개발자입니다.",
      portfolioUrl: "https://github.com/developer",
      preferredSchedule: "주말 오후",
      hasExperience: true
    )

    // When
    let result = try await repository.completeOnboarding(
      inviteCode: onboardingRequest.inviteCode,
      selectedTeamId: onboardingRequest.selectedTeamId,
      selectedPartId: onboardingRequest.selectedPartId,
      introduction: onboardingRequest.introduction,
      portfolioUrl: onboardingRequest.portfolioUrl,
      preferredSchedule: onboardingRequest.preferredSchedule,
      hasExperience: onboardingRequest.hasExperience
    )

    // Then
    #expect(result.isSuccessful == true)
    #expect(result.userId == 12345)
    #expect(result.assignedTeam == "iOS")
    #expect(result.assignedPart == "iOS 개발자")
    #expect(result.generation == "10기")
    #expect(result.welcomeMessage == "DDD 10기 iOS팀에 오신 것을 환영합니다!")
    #expect(result.nextSteps.count == 3)
    #expect(result.nextSteps[0] == "팀 채널 가입")
    #expect(result.nextSteps[1] == "첫 번째 모임 일정 확인")
    #expect(result.nextSteps[2] == "프로필 설정 완료")
  }

  @Test("권한 요청 설정 API 호출 성공")
  func test_setup_permissions_api_success() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When & Then
    try await repository.setupPermissions(
      cameraPermission: true,
      notificationPermission: true,
      locationPermission: false
    )

    // 성공적으로 완료되었음을 확인
    #expect(true)
  }

  @Test("온보딩 진행 상태 조회 API 호출 성공")
  func test_fetch_onboarding_progress_api_success() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When
    let result = try await repository.fetchOnboardingProgress(userId: 12345)

    // Then
    #expect(result.userId == 12345)
    #expect(result.currentStep == 3)
    #expect(result.totalSteps == 5)
    #expect(result.completedSteps.count == 2)
    #expect(result.completedSteps[0].stepNumber == 1)
    #expect(result.completedSteps[0].stepName == "초대 코드 검증")
    #expect(result.completedSteps[0].isCompleted == true)
    #expect(result.completedSteps[1].stepNumber == 2)
    #expect(result.completedSteps[1].stepName == "팀/직무 선택")
    #expect(result.completedSteps[1].isCompleted == true)
    #expect(result.progressPercentage == 40.0) // 2/5 * 100
    #expect(result.isCompleted == false)
  }

  // MARK: - API 호출 실패 테스트

  @Test("초대 코드 검증 API 호출 실패 (잘못된 형식)")
  func test_validate_invite_code_api_invalid_format() async throws {
    // Given
    let repository = createMockOnBoardingRepository()
    let invalidCode = "INVALID"

    // When & Then
    #expect(throws: OnBoardingError.invalidInviteCodeFormat) {
      try await repository.validateInviteCode(inviteCode: invalidCode)
    }
  }

  @Test("온보딩 완료 API 호출 실패 (팀 정원 초과)")
  func test_complete_onboarding_api_team_full() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When & Then
    #expect(throws: OnBoardingError.teamCapacityExceeded) {
      try await repository.completeOnboarding(
        inviteCode: "DDD2025INVITE",
        selectedTeamId: 999, // 정원 초과를 트리거하는 팀 ID
        selectedPartId: 1,
        introduction: "테스트",
        portfolioUrl: nil,
        preferredSchedule: "주말",
        hasExperience: false
      )
    }
  }

  @Test("온보딩 완료 API 호출 실패 (중복 등록)")
  func test_complete_onboarding_api_duplicate_registration() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When & Then
    #expect(throws: OnBoardingError.duplicateRegistration) {
      try await repository.completeOnboarding(
        inviteCode: "DDD2025DUPLICATE",
        selectedTeamId: 1,
        selectedPartId: 1,
        introduction: "중복 등록 테스트",
        portfolioUrl: nil,
        preferredSchedule: "평일",
        hasExperience: true
      )
    }
  }

  @Test("온보딩 진행 상태 조회 API 호출 실패 (사용자 없음)")
  func test_fetch_onboarding_progress_api_user_not_found() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When & Then
    #expect(throws: OnBoardingError.userNotFound) {
      try await repository.fetchOnboardingProgress(userId: -9999)
    }
  }

  @Test("네트워크 오류 처리")
  func test_network_error_handling() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When & Then
    #expect(throws: OnBoardingError.networkError) {
      try await repository.validateInviteCode(inviteCode: "NETWORK_ERROR") // 네트워크 오류를 트리거하는 값
    }
  }

  // MARK: - DTO to Entity 매핑 테스트

  @Test("InviteCodeValidationResponseDTO to InviteCodeValidationEntity 매핑")
  func test_invite_code_validation_response_dto_mapping() throws {
    // Given
    let expiryDate = Date().addingTimeInterval(2592000) // 30일 후

    let dto = InviteCodeValidationResponseDTO(
      isValid: true,
      inviteCode: "DDD2025TEST",
      organizationName: "DDD Test Community",
      generation: "테스트기",
      availableTeams: ["iOS", "Android", "웹", "백엔드", "디자인"],
      maxMembers: 50,
      currentMembers: 25,
      message: "테스트용 유효한 초대 코드",
      expiresAt: expiryDate,
      expiredAt: nil
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.isValid == true)
    #expect(entity.inviteCode == "DDD2025TEST")
    #expect(entity.organizationName == "DDD Test Community")
    #expect(entity.generation == "테스트기")
    #expect(entity.availableTeams.count == 5)
    #expect(entity.availableTeams.contains("iOS"))
    #expect(entity.availableTeams.contains("디자인"))
    #expect(entity.maxMembers == 50)
    #expect(entity.currentMembers == 25)
    #expect(entity.message == "테스트용 유효한 초대 코드")
    #expect(entity.expiresAt == expiryDate)
    #expect(entity.expiredAt == nil)
  }

  @Test("TeamDTO to TeamEntity 매핑")
  func test_team_dto_mapping() throws {
    // Given
    let dto = TeamDTO(
      teamId: 99,
      teamName: "테스트팀",
      description: "테스트용 팀입니다",
      maxMembers: 10,
      currentMembers: 3,
      isAvailable: true,
      teamLead: "팀장님",
      techStack: ["Swift", "SwiftUI", "TCA"],
      meetingSchedule: "매주 토요일 오후 2시"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.teamId == 99)
    #expect(entity.teamName == "테스트팀")
    #expect(entity.description == "테스트용 팀입니다")
    #expect(entity.maxMembers == 10)
    #expect(entity.currentMembers == 3)
    #expect(entity.isAvailable == true)
    #expect(entity.teamLead == "팀장님")
    #expect(entity.techStack == ["Swift", "SwiftUI", "TCA"])
    #expect(entity.meetingSchedule == "매주 토요일 오후 2시")
  }

  @Test("PartDTO to PartEntity 매핑")
  func test_part_dto_mapping() throws {
    // Given
    let dto = PartDTO(
      partId: 88,
      partName: "테스트 개발자",
      description: "테스트용 직무",
      requiredSkills: ["Testing", "TDD", "Swift"],
      preferredTeams: ["테스트팀"],
      experienceLevel: "중급",
      responsibilities: ["테스트 작성", "코드 리뷰", "문서화"]
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.partId == 88)
    #expect(entity.partName == "테스트 개발자")
    #expect(entity.description == "테스트용 직무")
    #expect(entity.requiredSkills == ["Testing", "TDD", "Swift"])
    #expect(entity.preferredTeams == ["테스트팀"])
    #expect(entity.experienceLevel == "중급")
    #expect(entity.responsibilities == ["테스트 작성", "코드 리뷰", "문서화"])
  }

  @Test("OnboardingCompletionResponseDTO to OnboardingCompletionEntity 매핑")
  func test_onboarding_completion_response_dto_mapping() throws {
    // Given
    let completionDate = Date()

    let dto = OnboardingCompletionResponseDTO(
      isSuccessful: true,
      userId: 77777,
      assignedTeam: "테스트팀",
      assignedPart: "테스트 개발자",
      generation: "테스트기",
      welcomeMessage: "테스트팀에 오신 것을 환영합니다!",
      nextSteps: ["첫 번째 단계", "두 번째 단계", "세 번째 단계"],
      membershipStartDate: completionDate,
      teamChannelUrl: "https://slack.com/test-team",
      mentorInfo: MentorInfoDTO(name: "멘토님", contact: "mentor@test.com")
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.isSuccessful == true)
    #expect(entity.userId == 77777)
    #expect(entity.assignedTeam == "테스트팀")
    #expect(entity.assignedPart == "테스트 개발자")
    #expect(entity.generation == "테스트기")
    #expect(entity.welcomeMessage == "테스트팀에 오신 것을 환영합니다!")
    #expect(entity.nextSteps.count == 3)
    #expect(entity.nextSteps[0] == "첫 번째 단계")
    #expect(entity.membershipStartDate == completionDate)
    #expect(entity.teamChannelUrl == "https://slack.com/test-team")
    #expect(entity.mentorInfo?.name == "멘토님")
    #expect(entity.mentorInfo?.contact == "mentor@test.com")
  }

  @Test("OnboardingProgressDTO to OnboardingProgressEntity 매핑")
  func test_onboarding_progress_dto_mapping() throws {
    // Given
    let progressSteps = [
      OnboardingStepDTO(stepNumber: 1, stepName: "1단계", isCompleted: true, completedAt: Date()),
      OnboardingStepDTO(stepNumber: 2, stepName: "2단계", isCompleted: true, completedAt: Date()),
      OnboardingStepDTO(stepNumber: 3, stepName: "3단계", isCompleted: false, completedAt: nil)
    ]

    let dto = OnboardingProgressDTO(
      userId: 66666,
      currentStep: 3,
      totalSteps: 5,
      completedSteps: progressSteps,
      progressPercentage: 60.0,
      isCompleted: false,
      estimatedCompletionTime: Date().addingTimeInterval(3600)
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.userId == 66666)
    #expect(entity.currentStep == 3)
    #expect(entity.totalSteps == 5)
    #expect(entity.completedSteps.count == 3)
    #expect(entity.completedSteps[0].stepNumber == 1)
    #expect(entity.completedSteps[0].isCompleted == true)
    #expect(entity.completedSteps[2].isCompleted == false)
    #expect(entity.progressPercentage == 60.0)
    #expect(entity.isCompleted == false)
  }

  // MARK: - 경계값 테스트

  @Test("팀 정원이 0인 경우 처리")
  func test_team_with_zero_capacity() throws {
    // Given
    let dto = TeamDTO(
      teamId: 100,
      teamName: "제한팀",
      description: "정원이 0인 팀",
      maxMembers: 0,
      currentMembers: 0,
      isAvailable: false,
      teamLead: nil,
      techStack: [],
      meetingSchedule: nil
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.maxMembers == 0)
    #expect(entity.currentMembers == 0)
    #expect(entity.isAvailable == false)
    #expect(entity.teamLead == nil)
    #expect(entity.techStack.isEmpty)
    #expect(entity.meetingSchedule == nil)
  }

  @Test("빈 기술 스택을 가진 팀 처리")
  func test_team_with_empty_tech_stack() throws {
    // Given
    let dto = TeamDTO(
      teamId: 101,
      teamName: "기획팀",
      description: "기술 스택이 없는 기획팀",
      maxMembers: 5,
      currentMembers: 2,
      isAvailable: true,
      teamLead: "기획팀장",
      techStack: [],
      meetingSchedule: "매주 월요일"
    )

    // When
    let entity = dto.toDomain()

    // Then
    #expect(entity.teamName == "기획팀")
    #expect(entity.techStack.isEmpty)
    #expect(entity.isAvailable == true)
  }

  @Test("매우 긴 자기소개 텍스트 처리")
  func test_very_long_introduction_text() async throws {
    // Given
    let repository = createMockOnBoardingRepository()
    let longIntroduction = String(repeating: "안녕하세요! ", count: 200) // 매우 긴 자기소개

    // When
    let result = try await repository.completeOnboarding(
      inviteCode: "DDD2025INVITE",
      selectedTeamId: 1,
      selectedPartId: 1,
      introduction: longIntroduction,
      portfolioUrl: "https://github.com/developer",
      preferredSchedule: "주말",
      hasExperience: true
    )

    // Then
    #expect(result.isSuccessful == true)
  }

  @Test("100% 완료된 온보딩 진행 상태 처리")
  func test_completed_onboarding_progress() async throws {
    // Given
    let repository = createMockOnBoardingRepository()

    // When
    let result = try await repository.fetchOnboardingProgress(userId: 99999) // 완료된 상태를 반환하는 특수 값

    // Then
    #expect(result.userId == 99999)
    #expect(result.currentStep == 5)
    #expect(result.totalSteps == 5)
    #expect(result.progressPercentage == 100.0)
    #expect(result.isCompleted == true)
    #expect(result.completedSteps.count == 5)
    #expect(result.completedSteps.allSatisfy { $0.isCompleted })
  }

  // MARK: - 동시성 테스트

  @Test("동시 초대 코드 검증 요청 처리")
  func test_concurrent_invite_code_validation() async throws {
    // Given
    let repository = createMockOnBoardingRepository()
    let inviteCodes = ["DDD2025A", "DDD2025B", "DDD2025C", "DDD2025D", "DDD2025E"]

    // When
    await withTaskGroup(of: Void.self) { group in
      for code in inviteCodes {
        group.addTask {
          do {
            _ = try await repository.validateInviteCode(inviteCode: code)
          } catch {
            // 테스트에서는 에러를 무시하고 동시성 테스트에 집중
          }
        }
      }
    }

    // Then: 동시성 작업이 크래시나 데드락 없이 완료되어야 함
    #expect(true)
  }

  @Test("동시 온보딩 완료 요청 처리")
  func test_concurrent_onboarding_completion() async throws {
    // Given
    let repository = createMockOnBoardingRepository()
    let teamIds = [1, 2, 3, 4, 5]

    // When
    await withTaskGroup(of: Void.self) { group in
      for teamId in teamIds {
        group.addTask {
          do {
            _ = try await repository.completeOnboarding(
              inviteCode: "DDD2025INVITE",
              selectedTeamId: teamId,
              selectedPartId: 1,
              introduction: "동시성 테스트 \(teamId)",
              portfolioUrl: nil,
              preferredSchedule: "주말",
              hasExperience: false
            )
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

// MARK: - Mock MoyaProvider for OnBoarding

extension MockMoyaProvider where Target == OnBoardingService {

  override func request<T: Decodable>(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) async throws -> T {
    if let onBoardingTarget = target as? OnBoardingService {
      return try createMockOnBoardingResponse(for: onBoardingTarget) as! T
    }

    throw OnBoardingError.networkError
  }

  private func createMockOnBoardingResponse<T: Decodable>(for target: OnBoardingService) throws -> T {
    switch target {
    case .validateInviteCode(let inviteCode):
      if inviteCode == "INVALID" {
        throw OnBoardingError.invalidInviteCodeFormat
      }
      if inviteCode == "NETWORK_ERROR" {
        throw OnBoardingError.networkError
      }

      if inviteCode == "DDD2024EXPIRED" {
        let expiredResponse = InviteCodeValidationResponseDTO(
          isValid: false,
          inviteCode: "DDD2024EXPIRED",
          organizationName: "DDD Community",
          generation: "9기",
          availableTeams: [],
          maxMembers: 30,
          currentMembers: 30,
          message: "만료된 초대 코드입니다",
          expiresAt: nil,
          expiredAt: Date().addingTimeInterval(-86400)
        )
        return expiredResponse as! T
      }

      let validResponse = InviteCodeValidationResponseDTO(
        isValid: true,
        inviteCode: inviteCode,
        organizationName: "DDD Community",
        generation: "10기",
        availableTeams: ["iOS", "Android", "웹", "백엔드"],
        maxMembers: 30,
        currentMembers: 15,
        message: "유효한 초대 코드입니다",
        expiresAt: Date().addingTimeInterval(2592000),
        expiredAt: nil
      )
      return validResponse as! T

    case .fetchAvailableTeams:
      let teams = [
        TeamDTO(teamId: 1, teamName: "iOS", description: "iOS 앱 개발", maxMembers: 8, currentMembers: 6, isAvailable: true, teamLead: "iOS 팀장", techStack: ["Swift", "SwiftUI", "UIKit"], meetingSchedule: "매주 토요일 오후 2시"),
        TeamDTO(teamId: 2, teamName: "Android", description: "Android 앱 개발", maxMembers: 8, currentMembers: 5, isAvailable: true, teamLead: "Android 팀장", techStack: ["Kotlin", "Compose", "Android"], meetingSchedule: "매주 토요일 오후 3시"),
        TeamDTO(teamId: 3, teamName: "웹", description: "웹 프론트엔드 개발", maxMembers: 10, currentMembers: 8, isAvailable: true, teamLead: "웹 팀장", techStack: ["React", "TypeScript", "Next.js"], meetingSchedule: "매주 일요일 오후 2시"),
        TeamDTO(teamId: 4, teamName: "디자인", description: "UI/UX 디자인", maxMembers: 4, currentMembers: 3, isAvailable: true, teamLead: "디자인 팀장", techStack: ["Figma", "Sketch", "Adobe"], meetingSchedule: "매주 토요일 오전 10시"),
        TeamDTO(teamId: 5, teamName: "백엔드", description: "백엔드 개발", maxMembers: 6, currentMembers: 6, isAvailable: false, teamLead: "백엔드 팀장", techStack: ["Spring", "Node.js", "AWS"], meetingSchedule: "매주 일요일 오후 3시")
      ]
      return teams as! T

    case .fetchAvailableParts:
      let parts = [
        PartDTO(partId: 1, partName: "iOS 개발자", description: "iOS 네이티브 앱 개발", requiredSkills: ["Swift", "SwiftUI", "UIKit"], preferredTeams: ["iOS"], experienceLevel: "초급-고급", responsibilities: ["iOS 앱 개발", "코드 리뷰", "문서화"]),
        PartDTO(partId: 2, partName: "Android 개발자", description: "Android 네이티브 앱 개발", requiredSkills: ["Kotlin", "Compose", "Android SDK"], preferredTeams: ["Android"], experienceLevel: "초급-고급", responsibilities: ["Android 앱 개발", "코드 리뷰", "테스트"]),
        PartDTO(partId: 3, partName: "웹 개발자", description: "웹 프론트엔드 개발", requiredSkills: ["React", "JavaScript", "CSS"], preferredTeams: ["웹"], experienceLevel: "초급-중급", responsibilities: ["웹 개발", "UI 구현", "성능 최적화"]),
        PartDTO(partId: 4, partName: "백엔드 개발자", description: "서버사이드 개발", requiredSkills: ["Java", "Spring", "MySQL"], preferredTeams: ["백엔드"], experienceLevel: "중급-고급", responsibilities: ["API 개발", "DB 설계", "인프라 구축"]),
        PartDTO(partId: 5, partName: "UI/UX 디자이너", description: "사용자 인터페이스 디자인", requiredSkills: ["Figma", "Sketch", "Adobe XD"], preferredTeams: ["디자인"], experienceLevel: "초급-중급", responsibilities: ["UI 디자인", "UX 리서치", "프로토타입"]),
        PartDTO(partId: 6, partName: "풀스택 개발자", description: "프론트엔드 + 백엔드 개발", requiredSkills: ["JavaScript", "TypeScript", "React", "Node.js"], preferredTeams: ["웹", "백엔드"], experienceLevel: "중급-고급", responsibilities: ["풀스택 개발", "아키텍처 설계", "DevOps"])
      ]
      return parts as! T

    case .completeOnboarding(let request):
      if request.selectedTeamId == 999 {
        throw OnBoardingError.teamCapacityExceeded
      }
      if request.inviteCode == "DDD2025DUPLICATE" {
        throw OnBoardingError.duplicateRegistration
      }

      let completion = OnboardingCompletionResponseDTO(
        isSuccessful: true,
        userId: 12345,
        assignedTeam: "iOS",
        assignedPart: "iOS 개발자",
        generation: "10기",
        welcomeMessage: "DDD 10기 iOS팀에 오신 것을 환영합니다!",
        nextSteps: ["팀 채널 가입", "첫 번째 모임 일정 확인", "프로필 설정 완료"],
        membershipStartDate: Date(),
        teamChannelUrl: "https://slack.com/ios-team",
        mentorInfo: MentorInfoDTO(name: "iOS 멘토", contact: "ios-mentor@ddd.com")
      )
      return completion as! T

    case .setupPermissions(_, _, _):
      return () as! T

    case .fetchOnboardingProgress(let userId):
      if userId == -9999 {
        throw OnBoardingError.userNotFound
      }

      if userId == 99999 {
        // 완료된 온보딩 진행 상태
        let completedSteps = [
          OnboardingStepDTO(stepNumber: 1, stepName: "초대 코드 검증", isCompleted: true, completedAt: Date()),
          OnboardingStepDTO(stepNumber: 2, stepName: "팀/직무 선택", isCompleted: true, completedAt: Date()),
          OnboardingStepDTO(stepNumber: 3, stepName: "자기소개 작성", isCompleted: true, completedAt: Date()),
          OnboardingStepDTO(stepNumber: 4, stepName: "권한 설정", isCompleted: true, completedAt: Date()),
          OnboardingStepDTO(stepNumber: 5, stepName: "최종 확인", isCompleted: true, completedAt: Date())
        ]

        let completedProgress = OnboardingProgressDTO(
          userId: 99999,
          currentStep: 5,
          totalSteps: 5,
          completedSteps: completedSteps,
          progressPercentage: 100.0,
          isCompleted: true,
          estimatedCompletionTime: nil
        )
        return completedProgress as! T
      }

      // 기본 진행 중 상태
      let progressSteps = [
        OnboardingStepDTO(stepNumber: 1, stepName: "초대 코드 검증", isCompleted: true, completedAt: Date()),
        OnboardingStepDTO(stepNumber: 2, stepName: "팀/직무 선택", isCompleted: true, completedAt: Date()),
        OnboardingStepDTO(stepNumber: 3, stepName: "자기소개 작성", isCompleted: false, completedAt: nil),
        OnboardingStepDTO(stepNumber: 4, stepName: "권한 설정", isCompleted: false, completedAt: nil),
        OnboardingStepDTO(stepNumber: 5, stepName: "최종 확인", isCompleted: false, completedAt: nil)
      ]

      let progress = OnboardingProgressDTO(
        userId: userId,
        currentStep: 3,
        totalSteps: 5,
        completedSteps: progressSteps,
        progressPercentage: 40.0,
        isCompleted: false,
        estimatedCompletionTime: Date().addingTimeInterval(1800)
      )
      return progress as! T

    default:
      throw OnBoardingError.networkError
    }
  }
}

// MARK: - Mock DTOs

struct InviteCodeValidationResponseDTO: Codable {
  let isValid: Bool
  let inviteCode: String
  let organizationName: String
  let generation: String
  let availableTeams: [String]
  let maxMembers: Int
  let currentMembers: Int
  let message: String
  let expiresAt: Date?
  let expiredAt: Date?

  func toDomain() -> InviteCodeValidationEntity {
    return InviteCodeValidationEntity(
      isValid: isValid,
      inviteCode: inviteCode,
      organizationName: organizationName,
      generation: generation,
      availableTeams: availableTeams,
      maxMembers: maxMembers,
      currentMembers: currentMembers,
      message: message,
      expiresAt: expiresAt,
      expiredAt: expiredAt
    )
  }
}

struct TeamDTO: Codable {
  let teamId: Int
  let teamName: String
  let description: String
  let maxMembers: Int
  let currentMembers: Int
  let isAvailable: Bool
  let teamLead: String?
  let techStack: [String]
  let meetingSchedule: String?

  func toDomain() -> TeamEntity {
    return TeamEntity(
      teamId: teamId,
      teamName: teamName,
      description: description,
      maxMembers: maxMembers,
      currentMembers: currentMembers,
      isAvailable: isAvailable,
      teamLead: teamLead,
      techStack: techStack,
      meetingSchedule: meetingSchedule
    )
  }
}

struct PartDTO: Codable {
  let partId: Int
  let partName: String
  let description: String
  let requiredSkills: [String]
  let preferredTeams: [String]
  let experienceLevel: String
  let responsibilities: [String]

  func toDomain() -> PartEntity {
    return PartEntity(
      partId: partId,
      partName: partName,
      description: description,
      requiredSkills: requiredSkills,
      preferredTeams: preferredTeams,
      experienceLevel: experienceLevel,
      responsibilities: responsibilities
    )
  }
}

struct OnboardingCompletionResponseDTO: Codable {
  let isSuccessful: Bool
  let userId: Int
  let assignedTeam: String
  let assignedPart: String
  let generation: String
  let welcomeMessage: String
  let nextSteps: [String]
  let membershipStartDate: Date
  let teamChannelUrl: String?
  let mentorInfo: MentorInfoDTO?

  func toDomain() -> OnboardingCompletionEntity {
    return OnboardingCompletionEntity(
      isSuccessful: isSuccessful,
      userId: userId,
      assignedTeam: assignedTeam,
      assignedPart: assignedPart,
      generation: generation,
      welcomeMessage: welcomeMessage,
      nextSteps: nextSteps,
      membershipStartDate: membershipStartDate,
      teamChannelUrl: teamChannelUrl,
      mentorInfo: mentorInfo?.toDomain()
    )
  }
}

struct MentorInfoDTO: Codable {
  let name: String
  let contact: String

  func toDomain() -> MentorInfoEntity {
    return MentorInfoEntity(name: name, contact: contact)
  }
}

struct OnboardingProgressDTO: Codable {
  let userId: Int
  let currentStep: Int
  let totalSteps: Int
  let completedSteps: [OnboardingStepDTO]
  let progressPercentage: Double
  let isCompleted: Bool
  let estimatedCompletionTime: Date?

  func toDomain() -> OnboardingProgressEntity {
    return OnboardingProgressEntity(
      userId: userId,
      currentStep: currentStep,
      totalSteps: totalSteps,
      completedSteps: completedSteps.map { $0.toDomain() },
      progressPercentage: progressPercentage,
      isCompleted: isCompleted,
      estimatedCompletionTime: estimatedCompletionTime
    )
  }
}

struct OnboardingStepDTO: Codable {
  let stepNumber: Int
  let stepName: String
  let isCompleted: Bool
  let completedAt: Date?

  func toDomain() -> OnboardingStepEntity {
    return OnboardingStepEntity(
      stepNumber: stepNumber,
      stepName: stepName,
      isCompleted: isCompleted,
      completedAt: completedAt
    )
  }
}

struct CompleteOnboardingRequest {
  let inviteCode: String
  let selectedTeamId: Int
  let selectedPartId: Int
  let introduction: String
  let portfolioUrl: String?
  let preferredSchedule: String
  let hasExperience: Bool
}

// MARK: - Mock Entities

struct InviteCodeValidationEntity {
  let isValid: Bool
  let inviteCode: String
  let organizationName: String
  let generation: String
  let availableTeams: [String]
  let maxMembers: Int
  let currentMembers: Int
  let message: String
  let expiresAt: Date?
  let expiredAt: Date?
}

struct TeamEntity {
  let teamId: Int
  let teamName: String
  let description: String
  let maxMembers: Int
  let currentMembers: Int
  let isAvailable: Bool
  let teamLead: String?
  let techStack: [String]
  let meetingSchedule: String?
}

struct PartEntity {
  let partId: Int
  let partName: String
  let description: String
  let requiredSkills: [String]
  let preferredTeams: [String]
  let experienceLevel: String
  let responsibilities: [String]
}

struct OnboardingCompletionEntity {
  let isSuccessful: Bool
  let userId: Int
  let assignedTeam: String
  let assignedPart: String
  let generation: String
  let welcomeMessage: String
  let nextSteps: [String]
  let membershipStartDate: Date
  let teamChannelUrl: String?
  let mentorInfo: MentorInfoEntity?
}

struct MentorInfoEntity {
  let name: String
  let contact: String
}

struct OnboardingProgressEntity {
  let userId: Int
  let currentStep: Int
  let totalSteps: Int
  let completedSteps: [OnboardingStepEntity]
  let progressPercentage: Double
  let isCompleted: Bool
  let estimatedCompletionTime: Date?
}

struct OnboardingStepEntity {
  let stepNumber: Int
  let stepName: String
  let isCompleted: Bool
  let completedAt: Date?
}

// MARK: - Mock Errors

enum OnBoardingError: Error {
  case invalidInviteCodeFormat
  case teamCapacityExceeded
  case duplicateRegistration
  case userNotFound
  case networkError
}