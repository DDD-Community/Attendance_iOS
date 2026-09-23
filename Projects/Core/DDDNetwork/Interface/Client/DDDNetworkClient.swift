//
//  DDDNetworkClient.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 일반 요청 / 멀티파트 업로드 / 파일 PUT 업로드를 모두 제공하는 클라이언트.
public protocol DDDNetworkClient: DDDRequestClient, DDDUploadClient, DDDFileUploadClient {}
