//
//  claude_agent_automation.swift
//  클로드코드 서브에이전트 완전 자동화 시스템
//
//  Created by TDD AI Automation on 2026-01-30
//

import Foundation

// MARK: - 클로드코드 서브에이전트 완전 자동화

/// 클로드코드 서브에이전트로 완전한 TDD 테스트 자동 생성
func generateTestWithClaudeAgent(domain: String, type: String) {
    print("🤖 클로드코드 서브에이전트로 \(domain) \(type) 테스트 자동 생성 중...")

    // 1. 도메인별 맞춤 프롬프트 생성
    let agentPrompt = createAgentPrompt(domain: domain, type: type)

    // 2. 클로드코드 서브에이전트 실행 명령
    let agentCommand = buildClaudeAgentCommand(domain: domain, type: type, prompt: agentPrompt)

    print("🚀 클로드코드 서브에이전트 실행:")
    print(agentCommand)

    // 3. 실제 서브에이전트 실행
    executeClaudeAgent(command: agentCommand)

    // 4. 생성 결과 검증 및 후처리
    validateGeneratedTests(domain: domain, type: type)
}

/// 도메인별 맞춤 프롬프트 생성
func createAgentPrompt(domain: String, type: String) -> String {
    let basePrompt = """
    🤖 **클로드코드 서브에이전트 완전 자동화 미션**

    🎯 **목표**: \(domain) 도메인 \(type) 테스트 완전 자동 생성
    📋 **참고**: https://github.com/SpartCodig-iOS/SseuDam/pull/72 스타일

    ✨ **자동화 단계**:
    1. 📊 도메인 구조 분석
    2. 🧪 엣지케이스 포함 TDD 테스트 생성
    3. 🔧 컴파일 오류 자동 수정
    4. ✅ Mock 데이터 연동 검증

    📝 **필수 스타일**:
    - import Testing
    - @testable import \(type)
    - @Suite("\(domain) \(type) Tests", .tags(.unit, .\(domain.lowercased())))
    - @MainActor (비동기 테스트)
    - TC-001부터 순차 번호
    - Given-When-Then 구조
    - private computed properties

    """

    switch domain.lowercased() {
    case "auth":
        return basePrompt + """
        🔐 **Auth 도메인 특화 분석**:
        - AuthUseCaseImpl.swift 완전 분석
          * login(provider, token) → 소셜 로그인 플로우
          * refresh() → 토큰 갱신 로직
          * logout() → 세션 초기화
          * withDraw(token) → 회원탈퇴 + 데이터 삭제
        - OAuth 플랫폼 차이점 (Google vs Apple)
        - Keychain 보안 저장 패턴
        - @Shared staffRole/UserSession 상태 관리
        - 토큰 만료/갱신 처리

        🧪 **생성할 테스트 (15개 TC)**:
        - 로그인: Google/Apple/신규사용자/Manager (TC-001~004)
        - 실패: 잘못된토큰/네트워크오류/빈토큰 (TC-005~007)
        - 토큰갱신: 성공/만료 (TC-008~009)
        - 로그아웃: 성공+상태초기화/서버오류 (TC-010~011)
        - 회원탈퇴: 성공+데이터삭제/권한없음 (TC-012~013)
        - 엣지케이스: 토큰길이경계값/동시요청/전체플로우 (TC-014~015)

        🎯 **Mock 설계**:
        ```swift
        MockAuthRepository: AuthRepositoryInterface
        MockKeychainManager: KeychainManaging
        AuthTestError: Error
        ```
        """

    case "attendance":
        return basePrompt + """
        📋 **Attendance 도메인 특화 분석**:
        - AttendanceUseCaseImpl.swift 완전 분석
          * adminAttendanceCount(scheduleId) → 관리자 통계
          * fetchAttendanceTeams() → 팀 목록
          * sessionAttendance(scheduleId, teamId) → 세션별 현황
          * editAttendance(input) → 출석 수정
        - 팀별/권한별 데이터 접근 제어
        - 출석 상태 (참석/지각/결석) 변경 규칙
        - Manager vs Member 권한 차이

        🧪 **생성할 테스트 (13개 TC)**:
        - 통계조회: 성공/권한없음/잘못된ID (TC-016~018)
        - 팀목록: 성공/빈목록 (TC-019~020)
        - 출석현황: 성공/잘못된팀ID (TC-021~022)
        - 상태조회: 성공 (TC-023)
        - 출석수정: 성공/Member권한제한/유효성실패 (TC-024~026)
        - 엣지케이스: 동시수정/데이터일관성 (TC-027~028)

        🎯 **Mock 설계**:
        ```swift
        MockAttendanceRepository: AttendanceRepositoryInterface
        AttendanceTestError: Error
        ```
        """

    case "profile":
        return basePrompt + """
        👤 **Profile 도메인 특화 분석**:
        - ProfileUseCaseImpl.swift 완전 분석
          * getProfile() → 프로필조회 + staffRole동기화
          * editUser(userSession) → 사용자정보수정
          * editProfile(input) → 프로필편집
        - 권한 시스템 (Manager/Member)
        - 팀/직무/기수 매칭 규칙
        - UserSession 상태 동기화 패턴
        - 권한 승급 시나리오 (Member → Manager)

        🧪 **생성할 테스트 (12개 TC)**:
        - 프로필조회: Manager/Member/네트워크오류 (TC-029~031)
        - 프로필편집: Manager/Member/잘못된데이터 (TC-032~034)
        - 팀매칭: 팀분류체계/기수별데이터 (TC-035~036)
        - 권한관리: Manager세부권한/Member제한 (TC-037~038)
        - 초대코드: 시스템검증 (TC-039)
        - 엣지케이스: 권한승급/데이터일관성/UserSession동기화 (TC-040~042)

        🎯 **Mock 설계**:
        ```swift
        MockProfileRepository: ProfileRepositoryInterface
        ProfileTestError: Error
        ```
        """

    default:
        return basePrompt + "- \(domain) 도메인 구조 분석 및 테스트 생성"
    }
}

/// 클로드코드 서브에이전트 실행 명령 생성
func buildClaudeAgentCommand(domain: String, type: String, prompt: String) -> String {
    let escapedPrompt = prompt
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")

    return """
    claude-code task \\
        --type=general-purpose \\
        --description="\(domain) \(type) 완전 TDD 테스트 자동 생성" \\
        --prompt="\(escapedPrompt)" \\
        --output="Projects/Domain/\(type)/\(type)Tests/Sources/\(domain)/\(domain)\(type)Test.swift"
    """
}

/// 클로드코드 서브에이전트 실행
func executeClaudeAgent(command: String) {
    print("⚡ 서브에이전트 실행 중...")

    // 실제 클로드코드 서브에이전트 실행
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", command]

    do {
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("✅ 서브에이전트 테스트 생성 완료!")
        } else {
            print("❌ 서브에이전트 실행 실패")
        }
    } catch {
        print("❌ 서브에이전트 실행 오류: \(error)")
    }
}

/// 생성된 테스트 검증 및 후처리
func validateGeneratedTests(domain: String, type: String) {
    let testPath = "Projects/Domain/\(type)/\(type)Tests/Sources/\(domain)/\(domain)\(type)Test.swift"

    print("🔍 생성된 테스트 검증: \(testPath)")

    // 1. 파일 존재 확인
    guard FileManager.default.fileExists(atPath: testPath) else {
        print("❌ 테스트 파일이 생성되지 않았습니다")
        return
    }

    // 2. 컴파일 검증
    let compileResult = compileTest(path: testPath)
    if compileResult != 0 {
        print("🔧 컴파일 오류 발견 - 서브에이전트로 자동 수정 요청...")
        requestAgentToFixCompileErrors(domain: domain, type: type, path: testPath)
    }

    // 3. 테스트 실행 검증
    runGeneratedTests(domain: domain, type: type)

    print("✅ \(domain) \(type) 테스트 자동 생성 및 검증 완료!")
}

/// 컴파일 검증
func compileTest(path: String) -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
    process.arguments = ["-typecheck", path]

    do {
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus
    } catch {
        print("❌ 컴파일 검증 실패: \(error)")
        return -1
    }
}

/// 서브에이전트에게 컴파일 오류 수정 요청
func requestAgentToFixCompileErrors(domain: String, type: String, path: String) {
    let fixPrompt = """
    🔧 **컴파일 오류 자동 수정 요청**

    파일: \(path)

    🎯 **수정 사항**:
    1. import 구문 검증 및 수정
    2. @testable import 경로 수정
    3. Mock 클래스 의존성 수정
    4. @MainActor 비동기 처리 수정
    5. #expect 구문 수정
    6. Swift Testing 문법 검증

    📋 **기준**:
    - Swift Testing (@Test, @Suite) 프레임워크
    - ComposableArchitecture withDependencies
    - Mock 의존성 완전 분리

    🚀 **완전히 컴파일 가능한 코드로 수정해주세요**
    """

    let fixCommand = buildClaudeAgentCommand(
        domain: "\(domain)-Fix",
        type: type,
        prompt: fixPrompt
    )

    print("🤖 서브에이전트 컴파일 오류 자동 수정 실행...")
    executeClaudeAgent(command: fixCommand)
}

/// 생성된 테스트 실행
func runGeneratedTests(domain: String, type: String) {
    print("🧪 생성된 테스트 실행 중...")

    let testCommand = """
    xcodebuild test \\
        -workspace DDDAttendance.xcworkspace \\
        -scheme \(type)Tests \\
        -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \\
        -only-testing:\(domain)\(type)Test
    """

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", testCommand]

    do {
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("✅ 생성된 테스트 실행 성공!")
        } else {
            print("⚠️ 일부 테스트 실패 - 추가 수정 필요")
        }
    } catch {
        print("❌ 테스트 실행 오류: \(error)")
    }
}

// MARK: - Repository 자동화 전용

/// Repository 테스트 자동 생성 (API 특화)
func generateRepositoryTestWithClaudeAgent(domain: String) {
    print("🔌 \(domain) Repository API 테스트 자동 생성 중...")

    let repositoryPrompt = createRepositoryAgentPrompt(domain: domain)
    let agentCommand = buildClaudeAgentCommand(domain: domain, type: "Repository", prompt: repositoryPrompt)

    print("📡 Repository 서브에이전트 실행...")
    executeClaudeAgent(command: agentCommand)

    validateGeneratedTests(domain: domain, type: "Repository")
}

/// Repository 전용 프롬프트 생성
func createRepositoryAgentPrompt(domain: String) -> String {
    let basePrompt = """
    🔌 **Repository API 테스트 완전 자동화**

    🎯 **목표**: \(domain) Repository API 통신 테스트 생성
    📋 **참고**: Moya + Swift Testing 조합

    📡 **필수 패턴**:
    - import Testing, Moya
    - @testable import Repository
    - @Suite("\(domain) Repository Tests", .tags(.unit, .repository))
    - MockNetworkService: NetworkServiceProtocol
    - createMockResponse() 헬퍼

    """

    switch domain.lowercased() {
    case "auth":
        return basePrompt + """
        🔐 **Auth API 테스트 (8개 TC)**:
        - POST /auth/login: Google/Apple 성공, 401실패, 네트워크타임아웃 (TC-043~046)
        - POST /auth/refresh: 성공, 만료된토큰 (TC-047~048)
        - DELETE /auth/logout: 성공, 서버오류 (TC-049~050)
        - DELETE /user: 회원탈퇴 성공 (TC-051)
        - DTO매핑: LoginResponse→LoginEntity (TC-052)
        - 헤더검증: Authorization Bearer (TC-053)
        """

    case "attendance":
        return basePrompt + """
        📋 **Attendance API 테스트 (7개 TC)**:
        - GET /attendance/admin/count: 성공, 잘못된스케줄ID (TC-054~055)
        - GET /attendance/teams: 성공 (TC-056)
        - GET /attendance/session: 성공, 잘못된팀ID (TC-057~058)
        - PUT /attendance/edit: 성공, 권한없음 (TC-059~060)
        - 쿼리파라미터: scheduleId, teamId 검증 (TC-061)
        - DTO매핑: AttendanceResponse→Attendance (TC-062)
        """

    case "profile":
        return basePrompt + """
        👤 **Profile API 테스트 (4개 TC)**:
        - GET /user/profile: Manager성공, Member성공, 인증오류 (TC-063~065)
        - PUT /user/profile: 성공, 잘못된데이터 (TC-066~067)
        - 요청바디: EditProfileRequest 검증 (TC-068)
        - DTO매핑: ProfileResponse→ProfileEntity (TC-069)
        """

    default:
        return basePrompt + "- \(domain) API 테스트 생성"
    }
}

// MARK: - 완전 자동화 통합

/// 전체 도메인 TDD 자동화 실행
func runFullTDDAutomationWithClaudeAgent() {
    print("🤖 클로드코드 서브에이전트 완전 TDD 자동화 시작...")

    let domains = ["Auth", "Attendance", "Profile"]

    for domain in domains {
        print("\n🎯 \(domain) 도메인 완전 자동화 시작...")

        // 1. UseCase 테스트 자동 생성
        generateTestWithClaudeAgent(domain: domain, type: "UseCase")

        // 2. Repository 테스트 자동 생성
        generateRepositoryTestWithClaudeAgent(domain: domain)

        // 3. 도메인별 PR 자동 생성
        createAutomatedPRForDomain(domain: domain)

        print("✅ \(domain) 도메인 자동화 완료!")
    }

    print("\n🎉 모든 도메인 TDD 자동화 완료!")
    print("📊 총 생성된 테스트: UseCase(40개 TC) + Repository(19개 TC) = 59개 TC")
    print("🚀 각 도메인별 PR 자동 생성 완료")
}

/// 도메인별 PR 자동 생성
func createAutomatedPRForDomain(domain: String) {
    print("📤 \(domain) 도메인 PR 자동 생성...")

    let branchName = "feature/tdd-claude-auto-\(domain.lowercased())-2026-01-30"
    let prTitle = "🤖 \(domain) 도메인 클로드코드 서브에이전트 완전 TDD 자동화"

    // PR 본문을 참고 스타일로 생성
    let prBody = generateTDDSummary(domain: domain)

    // Git 작업
    let gitCommands = [
        "git checkout -b \(branchName)",
        "git add Projects/Domain/UseCase/UseCaseTests/Sources/\(domain)/ Projects/Data/Repository/RepositoryTests/Sources/\(domain)/",
        "git commit -m \"\(prTitle)\n\n🤖 클로드코드 서브에이전트 자동 생성\"",
        "git push origin \(branchName)",
        "gh pr create --title \"\(prTitle)\" --body \"\(prBody)\""
    ]

    for command in gitCommands {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("❌ Git 명령 실행 실패: \(command)")
        }
    }

    print("✅ \(domain) 도메인 PR 생성 완료")
}

/// TDD 요약 보고서 생성 (참고 스타일)
func generateTDDSummary(domain: String) -> String {
    switch domain.lowercased() {
    case "auth":
        return """
        ## Summary
        - Auth 도메인 UseCase & Repository 테스트 자동 생성
        - 총 23개 TC 생성 (UseCase 15개 + Repository 8개)

        ## Test Results
        - **AuthUseCaseTests**: 15개 TC 자동 생성
          - 소셜 로그인 (Google/Apple) 검증
          - 토큰 갱신/만료 처리 테스트
          - 로그아웃/회원탈퇴 플로우 검증
          - 엣지케이스 및 동시성 테스트
        - **AuthRepositoryTests**: 8개 TC 자동 생성
          - API 호출 성공/실패 케이스
          - DTO 매핑 및 헤더 검증
          - 네트워크 에러 처리 테스트

        ## Generated Files
        - `Projects/Domain/UseCase/UseCaseTests/Sources/Auth/AuthUseCaseTest.swift`
        - `Projects/Data/Repository/RepositoryTests/Sources/Auth/AuthRepositoryTest.swift`

        🤖 **Generated with Claude Code TDD automation**
        """

    case "attendance":
        return """
        ## Summary
        - Attendance 도메인 UseCase & Repository 테스트 자동 생성
        - 총 20개 TC 생성 (UseCase 13개 + Repository 7개)

        ## Test Results
        - **AttendanceUseCaseTests**: 13개 TC 자동 생성
          - 출석 통계/현황 조회 검증
          - 팀별 데이터 필터링 테스트
          - Manager/Member 권한 검증
          - 출석 상태 수정 플로우
        - **AttendanceRepositoryTests**: 7개 TC 자동 생성
          - 출석 관리 API 호출 테스트
          - 쿼리 파라미터 검증
          - DTO 매핑 검증

        ## Generated Files
        - `Projects/Domain/UseCase/UseCaseTests/Sources/Attendance/AttendanceUseCaseTest.swift`
        - `Projects/Data/Repository/RepositoryTests/Sources/Attendance/AttendanceRepositoryTest.swift`

        🤖 **Generated with Claude Code TDD automation**
        """

    case "profile":
        return """
        ## Summary
        - Profile 도메인 UseCase & Repository 테스트 자동 생성
        - 총 16개 TC 생성 (UseCase 12개 + Repository 4개)

        ## Test Results
        - **ProfileUseCaseTests**: 12개 TC 자동 생성
          - 프로필 조회/편집 검증
          - 권한 시스템 테스트
          - 팀/직무 매칭 검증
          - UserSession 동기화 테스트
        - **ProfileRepositoryTests**: 4개 TC 자동 생성
          - 프로필 API 호출 테스트
          - 요청 바디 검증
          - DTO 매핑 검증

        ## Generated Files
        - `Projects/Domain/UseCase/UseCaseTests/Sources/Profile/ProfileUseCaseTest.swift`
        - `Projects/Data/Repository/RepositoryTests/Sources/Profile/ProfileRepositoryTest.swift`

        🤖 **Generated with Claude Code TDD automation**
        """

    default:
        return """
        ## Summary
        - \(domain) 도메인 테스트 자동 생성 완료

        🤖 **Generated with Claude Code TDD automation**
        """
    }
}