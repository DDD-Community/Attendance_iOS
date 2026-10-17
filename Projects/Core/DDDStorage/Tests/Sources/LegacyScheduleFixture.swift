// 별도 테스트 모듈에서 1.0.9 스키마로 실제 SwiftData 파일을 만든다.
// 1.0.9(067600a4)의 저장 속성과 모델 이름을 유지하는 읽기 전용 호환 모델.
import Foundation
import SwiftData

@Model
final class ScheduleCacheEntity {
  @Attribute(.unique) var id: Int
  var cachedAt: Date
  var name: String
  var scheduleDescription: String
  var month: Int
  var day: Int
  var year: Int

  init(
    id: Int,
    cachedAt: Date,
    name: String,
    scheduleDescription: String,
    month: Int,
    day: Int,
    year: Int
  ) {
    self.id = id
    self.cachedAt = cachedAt
    self.name = name
    self.scheduleDescription = scheduleDescription
    self.month = month
    self.day = day
    self.year = year
  }
}
