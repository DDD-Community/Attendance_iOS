클로드코드 서브에이전트야, Profile 도메인을 상세 분석해줘:

1. UseCase 구조:
   - 파일 위치: Projects/Domain/UseCase/Sources/Profile/
   - public 메서드들과 시그니처
   - @Dependency 의존성들
   - @Shared 상태 관리
   - async/await 패턴
   - 에러 처리 방식

2. Repository 구조:
   - 파일 위치: Projects/Data/Repository/Sources/Profile/
   - API 호출 메서드들
   - DTO → Entity 매핑
   - 네트워크 에러 처리

3. Entity 구조:
   - Mock 데이터 확장 메서드들
   - 비즈니스 로직 검증 포인트

분석 결과를 테스트 케이스 생성에 활용할 수 있도록 구조화해줘.