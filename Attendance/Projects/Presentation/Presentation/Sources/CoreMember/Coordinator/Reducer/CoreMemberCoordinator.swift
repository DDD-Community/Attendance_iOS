//
//  CoreMemberCoordinator.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation
import ComposableArchitecture

import Utill
import TCACoordinators
import KeychainAccess
import Networkings

@Reducer
public struct CoreMemberCoordinator {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var eventModel: [DDDEventDTO] = []
    
    public init() {
      self.routes = [.root(.coreMember(.init()), embedInNavigationView: true)]
    }
    var routes: [Route<CoreMemberScreen.State>]
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case router(IndexedRouterActionOf<CoreMemberScreen>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
  }
  
  //MARK: - ViewAction
  @CasePathable
  public enum View {
    case backAction
    case backToRootAction
  }
  
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchEvent
    case fetchEventResponse(Result<[DDDEventDTO], CustomError>)
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    case presntLogin
    
  }
  
  @Dependency(FireStoreUseCase.self) var fireStoreUseCase
  public var body: some ReducerOf<Self> {
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
  
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<CoreMemberScreen>
  ) -> Effect<Action> {
    switch action {
      //MARK: - 운영진 프로필
    case .routeAction(id: _, action: .coreMember(.navigation(.presentMangerProfile))):
      state.routes.push(.mangeProfile(.init()))
      return .none
      
      //MARK: - 스케줄 화면
    case .routeAction(id: _, action: .coreMember(.navigation(.presentSchedule))):
      state.routes.push(.scheduleEvent(.init(eventModel: state.eventModel)))
      return .none
      
    case .routeAction(id: _, action: .coreMember(.navigation(.presentQrcode))):
      let userID = try? Keychain().get("userID")
      state.routes.push(.qrCode(.init(userID: userID)))
      return .none
      
      //MARK: - 로그아웃
    case .routeAction(id: _, action: .mangeProfile(.navigation(.tapLogOut))):
      return .send(.navigation(.presntLogin))
     
    case .routeAction(id: _, action: .mangeProfile(.navigation(.presentCreatByApp))):
      state.routes.push(.createByApp(.init()))
      return .none
      
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
    case .presntLogin:
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      
    case .fetchEvent:
      return .run { send in
        let fetchedDataResult = await Result {
          try await fireStoreUseCase.fetchFireStoreData(
            from: .event,
            as: DDDEvent.self,
            shouldSave: true
          )
        }
        
        switch fetchedDataResult {
        case let .success(fetchedData):
          let filterData = fetchedData.map { $0.toModel()}
          await send(.async(.fetchEventResponse(.success(filterData))))
        case let .failure(error):
          await send(.async(.fetchEventResponse(.failure(CustomError.map(error)))))
        }
      }
      
    case let .fetchEventResponse(fetchedData):
      switch fetchedData {
      case let .success(fetchedData):
        state.eventModel = fetchedData
      case let .failure(error):
        #logError("Error fetching data", error)
      }
      return .none
    }
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      
    }
  }
}


extension CoreMemberCoordinator {
  
  @Reducer(state: .equatable)
  public enum CoreMemberScreen{
    case coreMember(CoreMember)
    case qrCode(QrCode)
    case scheduleEvent(ScheduleEvent)
    case mangeProfile(MangerProfile)
    case createByApp(CreatByApp)
  }
}
