//
//  CustomDate.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 2/8/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct CustomDate {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action: Equatable {
    
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      }
    }
  }
}

