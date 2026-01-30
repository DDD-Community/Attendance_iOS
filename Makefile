# TDD 자동화 Makefile
# 프로젝트: DDD Attendance iOS

.PHONY: help tdd-all tdd-domain test generate clean

# 기본 타겟
help: ## 도움말 표시
	@echo "🧪 TDD 자동화 명령어"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "사용법:\n  make \033[36m<target>\033[0m\n\n타겟:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# TDD 자동화 실행
tdd-all: ## 모든 도메인에 대해 TDD 자동화 실행
	@echo "🚀 Starting TDD automation for all domains..."
	./scripts/tdd-automation.sh

tdd-domain: ## 특정 도메인에 대해 TDD 자동화 실행 (make tdd-domain DOMAIN=Attendance)
	@if [ -z "$(DOMAIN)" ]; then \
		echo "❌ Error: DOMAIN parameter required"; \
		echo "Usage: make tdd-domain DOMAIN=Attendance"; \
		exit 1; \
	fi
	@echo "🚀 Starting TDD automation for domain: $(DOMAIN)"
	./scripts/tdd-automation.sh $(DOMAIN)

tdd-auth: ## Auth 도메인 TDD 자동화
	./scripts/tdd-automation.sh Auth

tdd-attendance: ## Attendance 도메인 TDD 자동화
	./scripts/tdd-automation.sh Attendance

tdd-profile: ## Profile 도메인 TDD 자동화
	./scripts/tdd-automation.sh Profile

# 테스트 실행
test: generate ## 전체 테스트 실행
	@echo "🧪 Running all tests..."
	xcodebuild test \
		-workspace DDDAttendance.xcworkspace \
		-scheme DDDAttendance \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		-quiet

test-verbose: generate ## 전체 테스트 실행 (상세 로그)
	@echo "🧪 Running all tests with verbose output..."
	xcodebuild test \
		-workspace DDDAttendance.xcworkspace \
		-scheme DDDAttendance \
		-destination 'platform=iOS Simulator,name=iPhone 15'

# Tuist 관련
generate: ## Tuist 워크스페이스 생성
	@echo "🔧 Generating Tuist workspace..."
	tuist generate --no-open

clean: ## 파생 데이터 정리
	@echo "🧹 Cleaning derived data..."
	rm -rf ~/Library/Developer/Xcode/DerivedData/DDDAttendance-*
	tuist clean

install: ## Tuist 의존성 설치
	@echo "📦 Installing Tuist dependencies..."
	tuist install

# 개발 도구
setup: install generate ## 프로젝트 초기 설정
	@echo "✅ Project setup complete!"

format: ## 코드 포맷팅 (SwiftFormat 필요)
	@if command -v swiftformat >/dev/null 2>&1; then \
		echo "🎨 Formatting Swift code..."; \
		swiftformat .; \
	else \
		echo "⚠️  SwiftFormat not installed. Install with: brew install swiftformat"; \
	fi

lint: ## 코드 린팅 (SwiftLint 필요)
	@if command -v swiftlint >/dev/null 2>&1; then \
		echo "🔍 Linting Swift code..."; \
		swiftlint; \
	else \
		echo "⚠️  SwiftLint not installed. Install with: brew install swiftlint"; \
	fi

# GitHub 관련
pr: ## 현재 브랜치로 PR 생성
	@echo "🚀 Creating Pull Request..."
	@if command -v gh >/dev/null 2>&1; then \
		gh pr create --fill; \
	else \
		echo "❌ GitHub CLI not installed. Install with: brew install gh"; \
	fi

pr-draft: ## 드래프트 PR 생성
	@echo "📝 Creating Draft Pull Request..."
	@if command -v gh >/dev/null 2>&1; then \
		gh pr create --draft --fill; \
	else \
		echo "❌ GitHub CLI not installed. Install with: brew install gh"; \
	fi

# 배포 (기존 fastlane 연동)
build-qa: ## QA 빌드 (TestFlight)
	@echo "🚀 Building for QA (TestFlight)..."
	bundle exec fastlane QA

build-release: ## Release 빌드 (App Store) - 버전 필요
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION parameter required"; \
		echo "Usage: make build-release VERSION=1.0.1"; \
		exit 1; \
	fi
	@echo "🚀 Building for Release (App Store) version $(VERSION)..."
	bundle exec fastlane release version:$(VERSION)

# 상태 확인
status: ## 프로젝트 상태 확인
	@echo "📊 Project Status"
	@echo "=================="
	@echo "Git branch: $$(git branch --show-current)"
	@echo "Git status: $$(git status --porcelain | wc -l | tr -d ' ') files changed"
	@echo "Tuist version: $$(tuist version 2>/dev/null || echo 'Not installed')"
	@echo "Xcode version: $$(xcodebuild -version | head -1)"
	@echo ""
	@echo "📝 Test Files Status:"
	@find Projects -name "*Test.swift" -type f | wc -l | xargs echo "  Total test files:"
	@find Projects -name "*Test.swift" -type f -size 0 | wc -l | xargs echo "  Empty test files:"

# 디버그
debug-test: ## 테스트 디버깅 정보 출력
	@echo "🐛 Test Debugging Information"
	@echo "=============================="
	@echo "Available schemes:"
	@xcodebuild -workspace DDDAttendance.xcworkspace -list
	@echo ""
	@echo "Available simulators:"
	@xcrun simctl list devices ios | grep -E "iPhone|iPad" | head -5

debug-domains: ## 현재 도메인 구조 확인
	@echo "🏗️  Domain Structure"
	@echo "===================="
	@echo "Entity domains:"
	@find Projects/Domain/Entity/Sources -mindepth 1 -maxdepth 1 -type d | sed 's|.*/||' | sort
	@echo ""
	@echo "UseCase domains:"
	@find Projects/Domain/UseCase/Sources -mindepth 1 -maxdepth 1 -type d | sed 's|.*/||' | sort
	@echo ""
	@echo "Repository domains:"
	@find Projects/Data/Repository/Sources -mindepth 1 -maxdepth 1 -type d | sed 's|.*/||' | sort