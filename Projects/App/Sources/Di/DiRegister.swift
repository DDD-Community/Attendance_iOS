//
//  DiRegister.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 11/24/25.
//

import Foundation

import WeaveDI
import Core

extension WeaveDI.Container {
  private static let register = RegisterModule()

  /// 📦 Repository 등록
  static func registerRepositories() async {
    let repositories = [
      register.authRepositoryImplModule(),
      register.oAuthRepositoryImplModule(),
      register.qrCodeRepositoryImplModule(),
      register.signUpRepositoryImplModoule(),
      register.profileRepositoryImplModule(),
      register.scheduleRepositoryImplModule(),
      register.attendanceRepositoryImplModule()
    ]

    await repositories.asyncForEach { module in
      await module.register()
    }
  }

  // 차후에 di 등록 여기에서 처리
  static func registerDi() async {
  }

  /// 🔧 UseCase 등록
  static func registerUseCases() async {

    let useCases = [
      register.authUseCaseImplModule(),
      register.oAuthUseCaseImplModule(),
      register.qrCodeUseCaseImplModule(),
      register.signUpUseCaseImplModoule(),
      register.profileUseCaseImplModule(),
      register.scheduleUseCaseImplModule(),
      register.attendanceUseCaseImplModule()
      // 추가 UseCase들...
    ]

    await useCases.asyncForEach { module in
      await module.register()
    }
  }
}
