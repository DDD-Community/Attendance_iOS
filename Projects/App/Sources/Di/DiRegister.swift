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
      .register {
        let keychainManager = UnifiedDI.resolve(KeychainManaging.self) ?? KeychainManager()
        return KeychainTokenProvider(keychainManager: keychainManager) as TokenProviding
      }
      .register(ProfileInterface.self) { ProfileRepositoryImpl() }
      .register(AppUpdateInterface.self) { AppUpdateRepositoryImpl() as AppUpdateInterface }
    // MARK: - 로그인
      .register { AuthRepositoryImpl() as AuthInterface }
      .register { GoogleOAuthRepositoryImpl() as GoogleOAuthInterface }
      .register { AppleLoginRepositoryImpl() as AppleAuthRequestInterface }
      .register { AppleOAuthRepositoryImpl() as AppleOAuthInterface }
      .register { AppleOAuthProvider() as AppleOAuthProviderInterface }
      .register { GoogleOAuthProvider() as GoogleOAuthProviderInterface }
    // MARK: - 온보딩
      .register { OnBoardingRepositoryImpl()  as OnBoardingInterface }
      .register { SignUpRepositoryImpl() as SignUpInterface }
    // MARK: - 출석
      .register { AttendanceRepositoryImpl() as AttendanceInterface }
    // MARK: - 마이페이지
      .register { MyPageRepositoryImpl() as MyPageRepositoryInterface }
    // MARK: - 스케줄
      .register { ScheduleRepositoryImpl() as ScheduleInterface }
    // MARK: - QRCode
      .register { QRCodeRepositoryImpl() as QRCodeInterface }
      .configure()
  }
}
