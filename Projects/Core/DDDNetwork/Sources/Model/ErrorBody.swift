//
//  ErrorBody.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 출석 서버가 실패 응답에 담아 주는 바디. 성공 응답은 페이로드가 그대로 오므로 래퍼가 없다.
/// `code` 는 "VOTE_NOT_FOUND" 같은 문자열이며, 없을 수도 있어 전부 옵셔널로 받는다.
struct ErrorBody: Decodable {
  let code: String?
  let message: String?
}
