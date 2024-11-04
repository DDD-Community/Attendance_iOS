//
//  SelectTeamIteam.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/4/24.
//

import SwiftUI

public struct SelectTeamIteam: View {
  let content: String
  let isActive: Bool
  let completion: () -> Void
  
  public init(
    content: String,
    isActive: Bool,
    completion: @escaping () -> Void
  ) {
    self.content = content
    self.isActive = isActive
    self.completion = completion
  }
  
  public var body: some View {
    VStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(isActive ? Color.grayWhite : Color.gray90)
        .frame(height: 58)
        .cornerRadius(16)
        .overlay {
          HStack {
            Text(content)
              .pretendardCustomFont(textStyle: .body1NormalMedium)
              .foregroundStyle(isActive ? Color.textPrimary : Color.grayWhite)
            
            Spacer()
            
            Image(asset: isActive ? .acitveSelectTeam : .disableSelectPart)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
          }
          .padding(.horizontal, 20)
          .onTapGesture {
            completion()
          }
        }
        .onTapGesture {
          completion()
        }
    }
    .padding(.horizontal, 24)
  }
}
