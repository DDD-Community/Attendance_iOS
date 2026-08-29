//
//  DiRegister.swift
//  DDDAttendance
//
//  Created by DDD on 11/24/25.
//

import Foundation

import DomainInterface
import Foundations
import Repository
import UseCase

import Auth
import ComposableArchitecture
import WeaveDI

/// 기본 WeaveDI 관리자 (단순하고 안정적)
@MainActor
public final class AppDIManager: Sendable {
  public static let shared = AppDIManager()

  private init() {}

  /// 기본 WeaveDI 의존성 등록 (Repository만)
  public func registerDefaultDependencies() {
    // Repository 구현체들만 등록
    WeaveDI.builder
      // 🔧 인프라 계층 (PFW 단순성 원칙)
      .register { KeychainManager() as KeychainManaging }
      .register {
        let keychainManager = UnifiedDI.resolve(KeychainManaging.self) ?? KeychainManager()
        return KeychainTokenProvider(keychainManager: keychainManager) as TokenProviding
      }

      // 💾 LocalDataSource 계층 (SwiftData 캐시 싱글톤)
      .register { ProfileLocalDataSource() as ProfileLocalDataSourceProtocol }
      .register { ScheduleLocalDataSource() as ScheduleLocalDataSourceProtocol }
      // 🏗️ Repository 계층 (Clean Architecture + PFW)
      .register { AuthRepositoryImpl() as AuthInterface }
      .register { ProfileRepositoryImpl() as ProfileInterface }
      .register { AppUpdateRepositoryImpl() as AppUpdateInterface }
      // 🔐 OAuth Provider 계층 (PFW 조합 패턴)
      .register { GoogleOAuthRepositoryImpl() as GoogleOAuthInterface }
      .register { AppleLoginRepositoryImpl() as AppleAuthRequestInterface }
      .register { AppleOAuthRepositoryImpl() as AppleOAuthInterface }
      .register { AppleOAuthProvider() as AppleOAuthProviderInterface }
      .register { GoogleOAuthProvider() as GoogleOAuthProviderInterface }
      // 📝 비즈니스 로직 계층 (PFW 단일 책임)
      .register { OnBoardingRepositoryImpl() as OnBoardingInterface }
      .register { SignUpRepositoryImpl() as SignUpInterface }
      .register { AttendanceRepositoryImpl() as AttendanceInterface }
      .register { MyPageRepositoryImpl() as MyPageRepositoryInterface }
      .register { ScheduleRepositoryImpl() as ScheduleInterface }
      .register { QRCodeRepositoryImpl() as QRCodeInterface }
      .register { VoteRepositoryImpl() as VoteInterface }
      .configure()
  }
}
