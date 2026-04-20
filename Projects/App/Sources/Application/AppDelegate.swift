import UIKit
import WeaveDI
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // 🧠 메모리 관리 시스템 초기화 (우선) - 모듈 분리 완료시 활성화
    // Task { @MainActor in
    //   _ = MemoryPressureManager.shared
    //   #if DEBUG
    //   _ = MemoryLeakDetector.shared
    //   print("🚀 [AppDelegate] Memory management systems initialized")
    //   #endif
    // }

    // DI 관리자 초기화
    WeaveDI.Container.bootstrapInTask { @DIContainerActor _ in
      await AppDIManager.shared.registerDefaultDependencies()
    }

    return true
  }
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
  }
}
