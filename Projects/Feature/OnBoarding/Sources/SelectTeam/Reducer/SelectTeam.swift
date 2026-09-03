//
//  SelectTeam.swift
//  Presentation
//
//  Created by DDD on 11/4/24.
//

import DDDCoreLogger
import Foundation

import DDDCoreUtility
import DomainInterface
import UseCase
import Entity

import ComposableArchitecture
import OnBoardingInterface

@Reducer
public struct SelectTeam {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init() {}

    var activeButton: Bool = false
    var selectTeam: SelectTeams? = .unknown
    var loading: Bool = false
    var errorMessage: String?
    var teams: IdentifiedArrayOf<SelectTeamEntity> = .init(uniqueElements: [])
    var signUpUser: SignUpUser?
    var editProfile: ProfileEntity?


    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
    @Shared(.appStorage("editGeneration")) var editGeneration: Bool = false
    @Shared(.appStorage("staffRole")) var staffRole: Staff?
    @Presents var alert: AlertState<AlertAction>?
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)
    case scope(ScopeAction)
  }

  @CasePathable
  public enum ScopeAction {
      case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case selectTeamButton(selectTeam: SelectTeamEntity)
    case onAppear
    case signUp
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case getTeams
    case signUpUser
    case editProfile
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case teamListResponse(Result<[SelectTeamEntity], SignUpError>)
    case signUpUserResponse(Result<SignUpUser, SignUpError>)
    case editProfileResponse(Result<ProfileEntity, ProfileError>)
  }
  
  // MARK: - DelegateAction
  
  /// 이동 계약은 OnBoardingInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = SelectTeamDelegate
  
  nonisolated enum CancelID: Hashable {
    case selectTeam
    case signUpUser
    case editProfile
  }

  
  @Dependency(\.signUpUseCase) var signUpUseCase
  @Dependency(\.onBoardingUseCase) var onBoardingUseCase
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.continuousClock) var clock
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case .delegate(let delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)

        case .scope:
          return .none
      }
    }
    .ifLet(\.$alert, action: \.scope.alert)
  }
}

extension SelectTeam {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .selectTeamButton(let selectTeams):
        let selectTeam = selectTeams.teams
        let teamId = selectTeams.teamId

        if state.selectTeam == selectTeam {
          // 동일한 파트 재선택 → 해제
          state.selectTeam = nil
          state.$userSession.withLock {
            $0.selectTeam = .unknown
            $0.selectTeamId = nil
          }
          state.activeButton = false
          return .none
        }

        state.selectTeam = selectTeam
        state.$userSession.withLock {
          $0.selectTeam = selectTeam
          $0.selectTeamId = teamId
        }

        state.activeButton = true
  //      DDDLogger.debug("selectPart: \(state.userEntity.role)", category: .auth)
        return .none

        case .onAppear:
          return .send(.async(.getTeams))
            .cancellable(id: CancelID.selectTeam, cancelInFlight: true)

      case .signUp:
        // Manager인 경우 회원가입 시 팀매니징 자동 추가
        if state.userSession.userRole == .manager {
          state.$userSession.withLock {
            if !$0.managing.contains(.teamManaging) {
              $0.managing.append(.teamManaging)
            }
          }
        }

        return .run { [
          editGeneration = state.editGeneration
        ] send in
          if editGeneration == true {
            await send(.async(.editProfile))
          } else {
            await send(.async(.signUpUser))
          }
        }

    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentMember:
      return .none

    case .presentManager:
      return .none

      case .presentLogin:
        return .none

      case .presentProfile:
        return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .getTeams:
        state.loading = true
        return .run {
          [userSession =  state.userSession]
          send in
          let teamResult = await Result {
            try await onBoardingUseCase.fetchTeams(generationId: userSession.generationId)
          }
            .mapError(SignUpError.from)
          return await send(.inner(.teamListResponse(teamResult)))

        }
        .cancellable(id: CancelID.selectTeam, cancelInFlight: true)
        .cancellable(id: "allAuthRelatedEffects")

      case .signUpUser:
        return .run { [
          userSession = state.userSession
        ] send in
          let signUpUserResult = await Result {
            return try await signUpUseCase.registerUser(userSession: userSession)
          }
          .mapError(SignUpError.from)
          return await send(.inner(.signUpUserResponse(signUpUserResult)))
        }


      case .editProfile:
        return .run { [
          userSession = state.userSession
        ] send in
          let editProfileResult = await Result {
            return try await profileUseCase.editUser(userSession: userSession)
          }
          .mapError(ProfileError.from)
          return await send(.inner(.editProfileResponse(editProfileResult)))
        }
        .cancellable(id: CancelID.editProfile, cancelInFlight: true)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .teamListResponse(let result):
        switch result {
          case .success(let data):
            state.teams = .init(uniqueElements: data)
            state.loading = false
          case .failure(let error):
            DDDLogger.error("네트워크 에러: \(error.errorDescription ?? "알 수 없음")", category: .auth)
        }
        return .none

      case .signUpUserResponse(let result):
        switch result {
          case .success(let data):
            state.signUpUser = data
            state.$staffRole.withLock { $0 = state.userSession.userRole }

            if state.userSession.userRole == .manager {
              return .send(.delegate(.presentManager))
            } else {
              return .send(.delegate(.presentMember))
            }

          case .failure(let error):
            state.errorMessage = error.errorDescription
            state.alert = AlertState {
              TextState("회원가입 실패")
            } actions: {
              ButtonState(action: .confirmTapped) {
                TextState("확인")
              }
            } message: {
              TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
            }
            return .none
        }

      case .editProfileResponse(let result):
        switch result {
          case .success(let data):
            state.editProfile = data
            state.$editGeneration.withLock { $0 = false }
            state.$staffRole.withLock { $0 = data.role }
            state.$userSession.withLock {
              $0.userID = data.userID
              $0.name = data.name
              $0.generation = data.generation
              $0.selectTeam = data.team ?? .unknown
              $0.selectPart = data.jobRole
              $0.userRole = data.role
              $0.managing = data.manger ?? []
            }

            // 기수변경 완료 후 변경된 역할에 맞는 홈으로 이동 (운영진/멤버)
            if data.role == .manager {
              return .send(.delegate(.presentManager))
            } else {
              return .send(.delegate(.presentMember))
            }

          case .failure(let error):
            state.errorMessage = error.errorDescription
            state.$editGeneration.withLock { $0 = false }
            state.alert = AlertState {
              TextState("프로필 수정 실패")
            } actions: {
              ButtonState(action: .confirmTapped) {
                TextState("확인")
              }
            } message: {
              TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
            }
            return .none
        }

    }
  }
}
