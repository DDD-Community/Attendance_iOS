//
//  DiRegister.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 11/24/25.
//

import Foundation

import DomainInterface
import Repository
import Foundations
import UseCase

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
      .register { KeychainManager() as KeychainManaging }
      .register { KeychainTokenProvider(keychainManager: KeychainManager()) as TokenProviding }
      .register { ProfileRepositoryImpl() as ProfileInterface }

      // MARK: -  로그인 관련
      .register { AuthRepositoryImpl() as AuthInterface }
      .register { GoogleOAuthRepositoryImpl() as GoogleOAuthInterface }
      .register { AppleLoginRepositoryImpl() as AppleAuthRequestInterface }
      .register { AppleOAuthRepositoryImpl() as AppleOAuthInterface }
      .register { AppleOAuthProvider() as AppleOAuthProviderInterface }
      .register { GoogleOAuthProvider() as GoogleOAuthProviderInterface }
      // MARK: - 토큰 등록 관련
    // MARK: - 온보딩 관련
      .register { OnBoardingRepositoryImpl()  as OnBoardingInterface }
      .register { SignUpRepositoryImpl() as SignUpInterface }
    // MARK: - 출석 관련
      .register { AttendanceRepositoryImpl() as AttendanceInterface }
    // MARK: - 프로필 관련
    // MARK: - 스케줄 관련
      .register { ScheduleRepositoryImpl() as ScheduleInterface }
    // MARK: - QRCode 관련
      .register { QRCodeRepositoryImpl() as QRCodeInterface }
      .configure()
  }
}
