import SwiftUI
import UIKit

/// Xcode 26에서 SwiftUI 의존 테스트 번들을 안전하게 로드하기 위한 최소 호스트 앱입니다.
@main
final class DDDTestHostAppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    preloadSwiftUI()
    return true
  }

  /// Xcode 26.3은 테스트 번들을 로드하며 SwiftUI 메타데이터를 탐색하는데,
  /// 호스트 프로세스에 SwiftUI가 먼저 올라와 있지 않으면 그 과정에서 죽는다.
  /// 의존성 선언만으로는 dead_strip 이 걷어가므로 실제 타입을 만들어 링크를 붙든다.
  private func preloadSwiftUI() {
    _ = UIHostingController(rootView: EmptyView())
  }
}
