//
//  AuthCoordinator.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/2/24.
//

import Foundation

import Utill
import Entity

import ComposableArchitecture
import TCACoordinators
import OnBoarding

@Reducer
public struct AuthCoordinator {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var routes: [Route<AuthScreen.State>]
    
    public init() {
      @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
      self.routes = [.root(.login(.init(userSession: userSession)), embedInNavigationView: true)]
    }
  }
  
  public enum Action: FeatureAction, BindableAction {
    case binding(BindingAction<State>)
    case router(IndexedRouterActionOf<AuthScreen>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
  }
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case backAction
    case backToRootAction
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentStaff
    case presentMember
    case cleanup
  }
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .router(let routeAction):
        return routerAction(state: &state, action: routeAction)
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
      case .navigation(let navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)
      }
    }
    .forEachRoute(\.routes, action: \.router)
  }
}

// MARK: - Effect Cancellation IDs
nonisolated enum AuthCancelID: Hashable {
  case selectTeamEffects
  case onBoardingEffects
  case loginEffects
}

extension AuthCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<AuthScreen>
  ) -> Effect<Action> {
    switch action {

      // MARK: - 초대코드 입력
    case .routeAction(id: _, action: .login(.navigation(.presentSignUpInviteView))):
      state.routes.push(.onboarding(.init()))
      return .none

    case .routeAction(id: _, action: .login(.navigation(.presentStaffMain))):
      return .send(.navigation(.presentStaff))

    case .routeAction(id: _, action: .login(.navigation(.presentMemberMain))):
      return .send(.navigation(.presentMember))


      case .routeAction(id: _, action: .onboarding(.navigation(.presentStaff))):
        return .send(.navigation(.presentStaff))

      case .routeAction(id: _, action: .onboarding(.navigation(.presentMember))):
        return .send(.navigation(.presentMember))



    default:
      return .none
    }
  }

  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .backAction:
      state.routes.goBack()
      return .none

    case .backToRootAction:
      return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
        $0.goBackToRoot()
      }
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentStaff:
      return .none

    case .presentMember:
      return .none

    case .cleanup:
      return .merge(
        .cancel(id: AuthCancelID.selectTeamEffects),
        .cancel(id: AuthCancelID.onBoardingEffects),
        .cancel(id: AuthCancelID.loginEffects)
      )
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {

  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {

  }
}

extension AuthCoordinator {
  @Reducer(state: .equatable)
  public enum AuthScreen {
    case login(Login)
  case onboarding(OnBoardingCoordinator)
  }
}
