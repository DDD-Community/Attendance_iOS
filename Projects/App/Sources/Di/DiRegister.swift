//
//  DiRegister.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 11/24/25.
//

import Foundation

import DomainInterface
import Repository
import Core

import ComposableArchitecture
import WeaveDI
import Auth

/// 🚀 **앱 전역 DI 관리자**
public class AppDIManager: @unchecked Sendable {
  public static let shared = AppDIManager()

  private init() {}

  /// 🎯 기본 의존성들을 등록
  public func registerDefaultDependencies() async {
    // 🏗️ 1. WeaveDI.builder 패턴으로 실제 구현체들 등록
    WeaveDI.builder
      .register { AuthRepositoryImpl() as AuthInterface }
      .register { SignUpRepositoryImpl() as SignUpInterface }
      .register { AttendanceRepositoryImpl() as AttendanceInterface }
      .register { ProfileRepositoryImpl() as ProfileInterface }
      .register { ScheduleRepositoryImpl() as ScheduleInterface }
      .register { QRCodeRepositoryImpl() as QRCodeInterface }
      .register { OAuthRepositoryImpl() as OAuthInterface }
      .register { AppleLoginRepositoryImpl() as AppleAuthRequestInterface }  
      .configure()
    print("✅ DI Repository 등록 및 TCA 연동 완료!")
  }
}
