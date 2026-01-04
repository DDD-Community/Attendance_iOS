//
//  WebReducer.swift
//  Profile
//
//  Created by Wonji Suh  on 1/4/26.
//

import Foundation
import ComposableArchitecture


@Reducer
public struct WebReducer {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var url: String = ""

    public init(url: String) {
      self.url = url
    }
  }

  public enum Action {
    case backToRoot

  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .backToRoot:
          return .none
      }
    }
  }
}

