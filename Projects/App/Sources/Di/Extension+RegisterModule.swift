//
//   Extension+RegisterModule.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 11/24/25.
//


import WeaveDI
import Core
import Repository

public extension RegisterModule {

  var attendanceUseCaseImplModule:  @Sendable () -> Module {
    makeUseCaseWithRepository(
      AttendanceInterface.self,
      repositoryProtocol: AttendanceInterface.self,
      repositoryFallback: DefaultAttendanceRepositoryImpl(),
      factory: { repo in
        AttendanceUseCaseImpl(repository: repo)
      }
    )
  }

  var attendanceRepositoryImplModule: @Sendable () -> Module {
    makeDependency(AttendanceInterface.self) {
      AttendanceRepositoryImpl()
    }
  }

  var authUseCaseImplModule:  @Sendable () -> Module {
    makeUseCaseWithRepository(
      AuthInterface.self,
      repositoryProtocol: AuthInterface.self,
      repositoryFallback: DefaultAuthRepositoryImpl(),
      factory: { repo in
        AuthUseCaseImpl(repository: repo)
      }
    )
  }

  var authRepositoryImplModule: @Sendable () -> Module {
    makeDependency(AuthInterface.self) {
      AuthRepositoryImpl()
    }
  }

  var oAuthUseCaseImplModule:  @Sendable () -> Module {
    makeUseCaseWithRepository(
      OAuthInterface.self,
      repositoryProtocol: OAuthInterface.self,
      repositoryFallback: DefaultOAuthRepositoryImpl(),
      factory: { repo in
        OAuthUseCaseImpl(repository: repo)
      }
    )
  }

  var oAuthRepositoryImplModule: @Sendable () -> Module {
    makeDependency(OAuthInterface.self) {
      OAuthRepositoryImpl()
    }
  }

  var profileUseCaseImplModule: @Sendable  () -> Module {
    makeUseCaseWithRepository(
      ProfileInterface.self,
      repositoryProtocol: ProfileInterface.self,
      repositoryFallback: DefaultProfileRepositoryImpl(),
      factory: { repo in
        ProfileUseCaseImpl(repository: repo)
      }
    )
  }

  var profileRepositoryImplModule: @Sendable  () -> Module {
    makeDependency(ProfileInterface.self) {
      ProfileRepositoryImpl()
    }
  }

  var qrCodeUseCaseImplModule: @Sendable () -> Module {
    makeUseCaseWithRepository(
      QRCodeInterface.self,
      repositoryProtocol: QRCodeInterface.self,
      repositoryFallback: DefaultQRCodeRepositoryImpl(),
      factory: { repo in
        QRCodeUseCaseImpl(repository: repo)
      }
    )
  }

  var qrCodeRepositoryImplModule: @Sendable () -> Module {
    makeDependency(QRCodeInterface.self) {
      QRCodeRepositoryImpl()
    }
  }

  var scheduleUseCaseImplModule:  @Sendable () -> Module {
    makeUseCaseWithRepository(
      ScheduleInterface.self,
      repositoryProtocol: ScheduleInterface.self,
      repositoryFallback: DefaultScheduleRepositoryImpl(),
      factory: { repo in
        ScheduleUseCaseImpl(repository: repo)
      }
    )
  }

  var scheduleRepositoryImplModule: @Sendable () -> Module {
    makeDependency(ScheduleInterface.self) {
      ScheduleRepositoryImpl()
    }
  }

  var signUpUseCaseImplModoule: @Sendable () -> Module {
    makeUseCaseWithRepository(
      SignUpInterface.self,
      repositoryProtocol: SignUpInterface.self,
      repositoryFallback: DefaultSignUpRepositoryImpl(),
      factory: { repo in
        SignUpUseCaseImpl(repository: repo)
      }
    )
  }

  var signUpRepositoryImplModoule: @Sendable  () -> Module {
    makeDependency(SignUpInterface.self) {
      SignUpRepositoryImpl()
    }
  }
}
