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

/// 🚀 **PFW + WeaveDI 3.4.1 통합 DI 관리자**
@MainActor
public final class AppDIManager {
  public static let shared = AppDIManager()

  private init() {}

  /// 🎯 PFW 철학 + WeaveDI 3.4.1 패턴으로 의존성 등록
  public func registerDefaultDependencies() async {
    WeaveDI.builder
      // 🔧 인프라 계층 (PFW 단순성 원칙)
      .register { KeychainManager() as KeychainManaging }
      .register {
        let keychainManager = UnifiedDI.resolve(KeychainManaging.self) ?? KeychainManager()
        return KeychainTokenProvider(keychainManager: keychainManager) as TokenProviding
      }

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

      .configure()
  }

  /// 🎯 PFW 철학: 타입 안전한 의존성 해결
  nonisolated public func resolve<T>(_ type: T.Type) -> T? {
    return UnifiedDI.resolve(type)
  }
}
