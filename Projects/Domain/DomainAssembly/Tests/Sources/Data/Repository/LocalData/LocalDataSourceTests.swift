import Foundation
import SwiftData
import Testing

@testable import AppUpdateDomain
@testable import AttendanceDomain
@testable import AuthDomain
@testable import MyPageDomain
@testable import OnBoardingDomain
@testable import ProfileDomain
@testable import QRCodeDomain
@testable import ScheduleDomain
@testable import VoteDomain

@Suite("Repository local cache", .serialized)
struct LocalDataSourceTests {
  @Test("프로필 캐시는 초기 조회, 저장, 교체, 삭제를 지원한다")
  func profileCacheLifecycle() async throws {
    let container = try makeContainer(for: ProfileCacheEntity.self)
    let source = ProfileLocalDataSource(container: container)

    #expect(try await source.loadUser() == nil)

    let original = makeProfile(userID: 1, name: "첫 번째 사용자")
    try await source.saveUser(original)
    #expect(try await source.loadUser() == original)

    let replacement = makeProfile(
      userID: 2,
      name: "교체된 사용자",
      team: nil,
      managerRoles: nil
    )
    try await source.saveUser(replacement)
    #expect(try await source.loadUser() == replacement)
    #expect(try fetchCount(ProfileCacheEntity.self, in: container) == 1)

    try await source.clear()
    #expect(try await source.loadUser() == nil)
    #expect(try fetchCount(ProfileCacheEntity.self, in: container) == 0)
  }

  @Test("만료된 프로필 캐시는 조회 시 제거한다")
  func expiredProfileCacheIsRemoved() async throws {
    let container = try makeContainer(for: ProfileCacheEntity.self)
    let context = ModelContext(container)
    context.insert(
      ProfileCacheEntity(
        cacheKey: ProfileCacheKey.user,
        cachedAt: yesterday,
        userID: 10,
        name: "만료된 사용자",
        generation: "12기",
        teamRawValue: SelectTeams.ios1.rawValue,
        jobRoleRawValue: SelectParts.ios.rawValue,
        roleRawValue: Staff.member.rawValue,
        managerRolesRawValues: nil
      )
    )
    try context.save()

    let source = ProfileLocalDataSource(container: container)
    #expect(try await source.loadUser() == nil)
    #expect(try fetchCount(ProfileCacheEntity.self, in: container) == 0)
  }

  @Test("프로필 캐시 변환은 잘못된 enum 값을 기본값으로 복구한다")
  func profileCacheConversionFallbacks() {
    let cache = ProfileCacheEntity(
      cacheKey: ProfileCacheKey.user,
      cachedAt: .now,
      userID: 20,
      name: "복구 사용자",
      generation: "12기",
      teamRawValue: "존재하지 않는 팀",
      jobRoleRawValue: "존재하지 않는 파트",
      roleRawValue: "존재하지 않는 역할",
      managerRolesRawValues: [
        StaffManaging.photo.rawValue,
        "존재하지 않는 운영진 역할"
      ]
    )

    let profile = cache.toDomain()

    #expect(profile.team == nil)
    #expect(profile.jobRole == .all)
    #expect(profile.role == .member)
    #expect(profile.manger == [.photo])
    #expect(cache.isExpired == false)
  }

  @Test("일정 캐시는 날짜순 조회, 교체, 삭제를 지원한다")
  func scheduleCacheLifecycle() async throws {
    let container = try makeContainer(for: ScheduleCacheEntity.self)
    let source = ScheduleLocalDataSource(container: container)

    #expect(try await source.loadAll() == nil)

    let unordered = [
      makeSchedule(id: 3, month: 5, day: 2, year: 2027),
      makeSchedule(id: 1, month: 12, day: 31, year: 2026),
      makeSchedule(id: 2, month: 1, day: 1, year: 2027)
    ]
    try await source.saveAll(unordered)

    let loaded = try #require(try await source.loadAll())
    #expect(loaded.map(\.id) == [1, 2, 3])

    let replacement = makeSchedule(id: 4, month: 9, day: 1, year: 2028)
    try await source.saveAll([replacement])
    #expect(try await source.loadAll() == [replacement])
    #expect(try fetchCount(ScheduleCacheEntity.self, in: container) == 1)

    try await source.clear()
    #expect(try await source.loadAll() == nil)
    #expect(try fetchCount(ScheduleCacheEntity.self, in: container) == 0)
  }

  @Test("빈 일정 저장은 기존 캐시를 제거한다")
  func savingEmptySchedulesClearsCache() async throws {
    let container = try makeContainer(for: ScheduleCacheEntity.self)
    let source = ScheduleLocalDataSource(container: container)

    try await source.saveAll([makeSchedule()])
    try await source.saveAll([])

    #expect(try await source.loadAll() == nil)
    #expect(try fetchCount(ScheduleCacheEntity.self, in: container) == 0)
  }

  @Test("하나라도 만료된 일정이 있으면 전체 캐시를 제거한다")
  func expiredScheduleInvalidatesWholeCache() async throws {
    let container = try makeContainer(for: ScheduleCacheEntity.self)
    let context = ModelContext(container)
    context.insert(makeSchedule(id: 1).toCacheModel(cachedAt: .now))
    context.insert(makeSchedule(id: 2).toCacheModel(cachedAt: yesterday))
    try context.save()

    let source = ScheduleLocalDataSource(container: container)
    #expect(try await source.loadAll() == nil)
    #expect(try fetchCount(ScheduleCacheEntity.self, in: container) == 0)
  }

  @Test("일정 캐시 모델은 모든 값을 도메인 모델로 보존한다")
  func scheduleCacheConversion() {
    let schedule = makeSchedule(
      id: 42,
      name: "정기 모임",
      description: "오프라인 세션",
      month: 10,
      day: 17,
      year: 2027
    )
    let cache = schedule.toCacheModel()

    #expect(cache.toDomain() == schedule)
    #expect(cache.isExpired == false)
  }

}

private extension LocalDataSourceTests {
  var yesterday: Date {
    Calendar.current.date(byAdding: .day, value: -1, to: .now)!
  }

  func makeContainer<T: PersistentModel>(for model: T.Type) throws -> ModelContainer {
    let schema = Schema([model])
    return try ModelContainer(
      for: schema,
      configurations: ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true
      )
    )
  }

  func fetchCount<T: PersistentModel>(
    _ model: T.Type,
    in container: ModelContainer
  ) throws -> Int {
    try ModelContext(container).fetchCount(FetchDescriptor<T>())
  }

  func makeProfile(
    userID: Int = 1,
    name: String = "테스트 사용자",
    team: SelectTeams? = .ios1,
    managerRoles: [StaffManaging]? = [.teamManaging, .attendanceCheck]
  ) -> ProfileEntity {
    ProfileEntity(
      userID: userID,
      name: name,
      generation: "12기",
      team: team,
      jobRole: .ios,
      role: .manager,
      manger: managerRoles
    )
  }

  func makeSchedule(
    id: Int = 1,
    name: String = "테스트 일정",
    description: String = "테스트 설명",
    month: Int = 8,
    day: Int = 20,
    year: Int = 2027
  ) -> Schedule {
    Schedule(
      id: id,
      name: name,
      description: description,
      month: month,
      day: day,
      year: year
    )
  }
}
