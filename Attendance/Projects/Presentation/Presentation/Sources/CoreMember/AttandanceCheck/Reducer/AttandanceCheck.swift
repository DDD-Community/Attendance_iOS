//
//  AttandanceCheck.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/16/25.
//

import Foundation
import ComposableArchitecture

import Utill
import Networkings
import FirebaseAuth

@Reducer
public struct AttandanceCheck {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var selectAttandanceDate: Date = .now
    var selectPart: SelectTeam? = .web1
    
    var dividerWidths: [SelectTeam: CGFloat] = [:]
    var attendanceCheckInModel: [AttendanceDTO] = []
    var attendaceMemberModel : [MemberDTO] = []
    var user: User? =  nil
    
    var isLoading: Bool = false
    var attendanceCount: Int = .zero
    var lateCount: Int = .zero
    var absentCount: Int = .zero
    
    @Presents var destination: Destination.State?
    
    public init() {
      
    }
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case destination(PresentationAction<Destination.Action>)
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case selectDate(SelectDate)
  }
  
  //MARK: - ViewAction
  @CasePathable
  public enum View {
    case selectPartButton(selectPart: SelectTeam)
    case swipeNext
    case swipePrevious
    case appearSelectDate
    case closeModal
  }
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchMember
    case fetchAttenDance
    case fetchCurrentUser
    
    case observeAttendance
    case fetchUserDataResponse(Result<User, CustomError>)
    case fetchMemberDataResponse(Result<[MemberDTO], CustomError>)
    case fetchAttendanceDataResponse(Result<[AttendanceDTO], CustomError>)
    
    case upDateFetchAttandanceMember(selectPart: SelectTeam)
    
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    
    
  }
  
  private struct AttendanceCheckCancel: Hashable {}
  
  @Dependency(FireStoreUseCase.self) var fireStoreUseCase
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .destination(_):
        return .none
        
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
    .ifLet(\.$destination, action: \.destination)
  }
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .selectPartButton(let selectPart):
      state.selectPart = selectPart
      return .none
      
    case .swipeNext:
      guard let selectPart = state.selectPart else { return .none }
      if let currentIndex = SelectTeam.allCases.firstIndex(of: selectPart),
         currentIndex < SelectTeam.allCases.count - 1 {
        let nextPart = SelectTeam.allCases[currentIndex + 1]
        state.selectPart = nextPart
      }
      return .none
      
    case .swipePrevious:
      guard let selectPart = state.selectPart else { return .none }
      if let currentIndex = SelectTeam.allCases.firstIndex(of: selectPart),
         currentIndex > 0 {
        state.selectPart = SelectTeam.allCases[currentIndex - 1]
      }
      return .none
      
    case .appearSelectDate:
      state.destination = .selectDate(.init())
      return .none
      
    case .closeModal:
      state.destination = nil
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchMember:
      return .run {  send in
        let fetchedDataResult = await Result {
          try await fireStoreUseCase.fetchFireStoreData(
            from: .member,
            as: Attendance.self,
            shouldSave: false
          )
        }
        
        switch fetchedDataResult {
        case let .success(fetchedData):
          let filterData = fetchedData
            .filter { $0.memberType == .member || !$0.name.isEmpty }
            .map { $0.toMemberDTO() }
          await send(.async(.fetchMemberDataResponse(.success(filterData))))
          
        case let .failure(error):
          await send(.async(.fetchMemberDataResponse(.failure(CustomError.map(error)))))
        }
      }
      
      // MARK: - 실시간으로 데이터 가져오기 출석현황
    case .fetchAttenDance:
      return .run {  [attendanceCount = state.attendanceCount , lateCount = state.lateCount , absentCount = state.absentCount, selectAttandanceDate = state.selectAttandanceDate] send in
        let fetchedDataResult = await Result {
          try await fireStoreUseCase.fetchFireStoreData(
            from: .attendance,
            as: Attendance.self,
            shouldSave: false
          )
        }
        switch fetchedDataResult {
        case let .success(fetchedData):
//          await send(.async(.fetchMember))
          
          let filterData = fetchedData
            .map { $0.toAttendanceDTO() }
          var attendanceCount = filterData.filter { $0.status == .present }.count
          var lateCount = filterData.filter { $0.status == .late  }.count
          var absentCount = filterData.filter { $0.status == .absent }.count
          #logDebug("카운트", attendanceCount, lateCount, absentCount)
          await send(.async(.fetchAttendanceDataResponse(.success(filterData))))
          attendanceCount = attendanceCount 
          lateCount = lateCount
          absentCount = absentCount
          //          await send(.view(.updateAttendanceCountWithData(attendances: filterData)))
          
          
        case let .failure(error):
          await send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
        }
      }
      
    case .fetchCurrentUser:
      return .run {  send in
        let fetchUserResult = await Result {
          try await fireStoreUseCase.getCurrentUser()
        }
        
        switch fetchUserResult {
        case let .success(user):
          if let user = user {
            await send(.async(.fetchUserDataResponse(.success(user))))
          }
        case let .failure(error):
          await send(.async(.fetchUserDataResponse(.failure(CustomError.map(error)))))
        }
      }
      
    case .observeAttendance:
      return .run { send in
        for await result in try await fireStoreUseCase.observeFireBaseChanges(
          from: .attendance,
          as: Attendance.self
        ) {
          //                            // Map each Attendance model to AttendanceDTO and send the result
          
          switch result {
          case let .success(fetchedData):
  //          await send(.async(.fetchMember))
            let filterData = fetchedData
              .map { $0.toAttendanceDTO() }
            await send(.async(.fetchAttendanceDataResponse(.success(filterData))))
            
          case .failure(let error):
            await send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
          }
          //                            await send(.async(.fetchAttendanceDataResponse(dtoResult)))
        }
      }
      
    case let .upDateFetchAttandanceMember(selectPart: selectPart):
      let selectData = state.selectAttandanceDate
      return .run {  send in
        let fetchedAttandanceResult = await Result {
          try await fireStoreUseCase.fetchFireStoreData(
            from: .attendance,
            as: Attendance.self,
            shouldSave: false
          )
        }
        
        switch fetchedAttandanceResult {
        case let .success(fetchedData):
          let filteredData = fetchedData
            .filter {$0.memberTeam == selectPart  && $0.updatedAt.formattedDateToString() == selectData.formattedDateToString() }
            .map { $0.toAttendanceDTO() }
          await send(.async(.fetchAttendanceDataResponse(.success(filteredData))))
          
        case let .failure(error):
          await
          send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
        }
      }
      
    case let .fetchUserDataResponse(fetchUser):
      switch fetchUser {
      case let .success(fetchUser):
        state.user = fetchUser
        #logDebug("fetching data", fetchUser.uid)
      case let .failure(error):
        #logError("Error fetching User", error)
        state.user = nil
      }
      return .none
      
    case let .fetchAttendanceDataResponse(fetchedData):
      switch fetchedData {
      case let .success(fetchedAttendanceData):
        let filteredData = fetchedAttendanceData.filter {
          ($0.id.isEmpty == false) && $0.memberType == .member && !$0.name.isEmpty && $0.updatedAt.formattedDateToString() == state.selectAttandanceDate.formattedDateToString()
        }
        
        let selectedDate = state.selectAttandanceDate
        let selectedDay = Calendar.current.startOfDay(for: selectedDate)
        let today = Calendar.current.startOfDay(for: Date())
        
        let updatedData = filteredData.map { attendance -> AttendanceDTO in
          if !Calendar.current.isDate(attendance.updatedAt, inSameDayAs: selectedDay) {
            var modifiedAttendance = attendance
            modifiedAttendance.status = .notAttendance
            return modifiedAttendance
          }
          return attendance
        }
        let attendanceCount = filteredData.filter { $0.status == .present }.count
        let lateCount = filteredData.filter { $0.status == .late  }.count
        let absentCount = filteredData.filter { $0.status == .absent }.count
        state.attendanceCount = attendanceCount
        state.lateCount = lateCount
        state.absentCount = absentCount
        #logDebug("카운트", attendanceCount, lateCount, absentCount)
        
        if Calendar.current.isDate(selectedDate, inSameDayAs: today) {
          state.attendanceCheckInModel = updatedData
        } else {
          state.attendanceCheckInModel = updatedData
        }
        
      case let .failure(error):
        #logError("출석  정보 데이터 에러", error.localizedDescription)
        state.isLoading = true
      }
      return .none
      
    case let .fetchMemberDataResponse(fetchedData):
      switch fetchedData {
      case let .success(fetchedData):
        state.isLoading = false
        let filteredData = fetchedData.filter { $0.memberType == .member && !$0.name.isEmpty }
        state.attendaceMemberModel = filteredData
        
      case let .failure(error):
        #logError("Error fetching data", error)
        state.isLoading = true
      }
      return .none
    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
      
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
