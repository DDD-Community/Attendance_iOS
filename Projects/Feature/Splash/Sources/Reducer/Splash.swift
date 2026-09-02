//
//  Splash.swift
//  Presentation
//
//  Created by DDD on 10/29/24.
//

import DDDCoreLogger
import Foundation

import DDDDesignKit
import Entity
import DDDSharedUI
import UseCase
import DDDCoreUtility

import ComposableArchitecture

@Reducer
public struct Splash {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Shared(.inMemory("User")) var user: User = .shared
    @Shared(.appStorage("staffRole")) var staffRole: Staff?
    var profileModel: ProfileEntity?
    
    // 앱 업데이트 관련
    @Presents var customAlert: CustomAlertState<CustomAlertAction>?
    var appStoreUrl: String = ""
    var isUpdateCheckCompleted: Bool = false
    var profileFetchCompleted: Bool = false
    
    public init() {}
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    case scope(ScopeAction)
    
    @CasePathable
    public enum ScopeAction {
      case alert(PresentationAction<AlertAction>)
      case customAlert(PresentationAction<CustomAlertAction>)
    }
  }
  
  public enum AlertAction: Equatable {
    // 필요시 추가
  }
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case onAppear
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case fetchUser
    case checkAppUpdate
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case fetchUserResponse(Result<ProfileEntity, ProfileError>)
    case checkAppUpdateResponse(Result<AppUpdateInfo?, AppUpdateError>)
  }
  
  // MARK: - NavigationAction
  
  @CasePathable
  public enum NavigationAction: Equatable {
    case presentLogin
    case presentStaff
    case presentMember
  }
  
  nonisolated enum CancelID: Hashable {
    case fetchProfile
    case checkAppUpdate
  }
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.appUpdateUseCase) var appUpdateUseCase
  @Dependency(\.openURL) var openURL
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.keychainManager) var keychainManager
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .view(viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      case let .async(asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      case let .inner(innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
      case let .navigation(navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)
        
      case .scope(.customAlert(.presented(.confirmTapped))):
        // 앱스토어로 이동
        return .run { [appStoreUrl = state.appStoreUrl] _ in
          if let url = URL(string: appStoreUrl) {
            await openURL(url)
          }
        }
        
      case .scope(.customAlert(.presented(.cancelTapped))):
        // "나중에 할게요" 선택 시 팝업을 닫고 화면 이동
        state.customAlert = nil
        if state.profileFetchCompleted {
          return navigateToNextScreen(state: &state)
        }
        return .none
        
      case .scope:
        return .none
      }
    }
    .ifLet(\.$customAlert, action: \.scope.customAlert) {
      EmptyReducer()
    }
  }
}

extension Splash {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      let staffRole = state.staffRole
      return .run { send in
        // 먼저 딜레이를 주고
        try await clock.sleep(for: .seconds(0.5))
        
        // 앱 업데이트 체크 (백그라운드에서)
        await send(.async(.checkAppUpdate))
        
        if staffRole == .manager {
          DDDLogger.debug("👔 [Splash] Redirecting to staff", category: .app)
          await send(.async(.fetchUser))
        } else if staffRole == .member {
          DDDLogger.debug("👤 [Splash] Redirecting to member", category: .app)
          await send(.async(.fetchUser))
        } else {
          DDDLogger.debug("❓ [Splash] No staff role - redirecting to login", category: .app)
          await send(.navigation(.presentLogin))
        }
      }
      .cancellable(id: CancelID.fetchProfile, cancelInFlight: true)
    }
  }
  
  private func handleAsyncAction(
    state _: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchUser:
      return .run { send in
        let fetchUserResult = await Result {
          try await profileUseCase.getProfile()
        }
          .mapError(ProfileError.from)
        try await clock.sleep(for: .seconds(1))
        return await send(.inner(.fetchUserResponse(fetchUserResult)))
      }
      .cancellable(id: CancelID.fetchProfile, cancelInFlight: true)
      
    case .checkAppUpdate:
      return .run { send in
        let updateResult = await Result {
          try await appUpdateUseCase.checkForUpdate()
        }
          .mapError(AppUpdateError.from)
        await send(.inner(.checkAppUpdateResponse(updateResult)))
      }
      .cancellable(id: CancelID.checkAppUpdate, cancelInFlight: true)
    }
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .fetchUserResponse(result):
      switch result {
      case let .success(profileDTOData):
        DDDLogger.debug("[Splash] User profile fetched successfully", category: .app)
        state.profileModel = profileDTOData
        state.profileFetchCompleted = true
        
        // 업데이트 체크가 완료되고 팝업이 없는 경우에만 화면 이동
        if state.isUpdateCheckCompleted && state.customAlert == nil {
          return navigateToNextScreen(state: &state)
        }
        
        return .none
        
      case let .failure(error):
        DDDLogger.error("❌ [Splash] Failed to fetch user profile: \(error.localizedDescription)", category: .app)
        
        // 토큰 만료나 인증 에러의 경우 로그인으로 이동
        // 다른 네트워크 에러의 경우에도 안전하게 로그인으로 이동
        return .run { send in
          keychainManager.clear()
          await send(.navigation(.presentLogin))
        }
      }
      
    case let .checkAppUpdateResponse(result):
      state.isUpdateCheckCompleted = true
      
      switch result {
      case let .success(updateInfo):
        // 업데이트가 필요한 경우에만 Alert 표시
        if let updateInfo = updateInfo {
          DDDLogger.debug("[Splash] App update available: \(updateInfo.latestVersion)", category: .app)
          state.appStoreUrl = updateInfo.appStoreUrl
          
          // 릴리즈 노트에서 실제 버전 추출
          let actualVersion = extractVersionFromReleaseNotes(
            releaseNotes: updateInfo.releaseNotes,
            fallbackVersion: updateInfo.latestVersion
          )
          
          let message = "새로운 버전 \(actualVersion)이 출시되었습니다!\n\n더 나은 경험을 위해 지금 업데이트하세요!"
          
          state.customAlert = .alert(
            title: "새로운 버전이 출시되었어요!",
            message: message,
            confirmTitle: "지금 업데이트",
            cancelTitle: "나중에 할게요",
            isDestructive: false
          )
        } else {
          DDDLogger.debug("[Splash] App is up to date", category: .app)
          
          // 업데이트가 없고 프로필 fetch가 완료되었다면 화면 이동
          if state.profileFetchCompleted {
            return navigateToNextScreen(state: &state)
          }
        }
        return .none
        
      case let .failure(error):
        DDDLogger.error("[Splash] Failed to check app update: \(error.localizedDescription)", category: .app)
        
        // 에러가 발생해도 프로필 fetch가 완료되었다면 화면 이동
        if state.profileFetchCompleted {
          return navigateToNextScreen(state: &state)
        }
        return .none
      }
    }
  }
  
  private func handleNavigationAction(
    state _: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogin:
      return .none
      
    case .presentStaff:
      return .none // fetchUser는 이미 onAppear에서 처리됨
      
    case .presentMember:
      return .none // fetchUser는 이미 onAppear에서 처리됨
    }
  }
  
  private func navigateToNextScreen(state: inout State) -> Effect<Action> {
    let staffRole = state.staffRole
    
    if staffRole == .manager {
      DDDLogger.debug("[Splash] Navigation to staff after checks completed", category: .app)
      return .send(.navigation(.presentStaff))
    } else if staffRole == .member {
      DDDLogger.debug("[Splash] Navigation to member after checks completed", category: .app)
      return .send(.navigation(.presentMember))
    } else {
      DDDLogger.debug("[Splash] No staff role after checks completed - redirecting to login", category: .app)
      return .send(.navigation(.presentLogin))
    }
  }
  
  private func extractVersionFromReleaseNotes(
    releaseNotes: String?,
    fallbackVersion: String
  ) -> String {
    guard let releaseNotes = releaseNotes else {
      return fallbackVersion
    }
    
    // "[v 1.0.2]" 또는 "v 1.0.2" 패턴에서 버전 추출
    let patterns = [
      #"\[v\s*([0-9]+\.[0-9]+\.[0-9]+)\]"#, // [v 1.0.2]
      #"v\s*([0-9]+\.[0-9]+\.[0-9]+)"#, // v 1.0.2
    ]
    
    for pattern in patterns {
      if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
        let range = NSRange(location: 0, length: releaseNotes.count)
        if let match = regex.firstMatch(in: releaseNotes, range: range) {
          let versionRange = Range(match.range(at: 1), in: releaseNotes)
          if let versionRange = versionRange {
            return String(releaseNotes[versionRange])
          }
        }
      }
    }
    
    return fallbackVersion
  }
}
