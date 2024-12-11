//
//  SelectPartItem.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/3/24.
//

import SwiftUI

public struct SelectPartItem: View {
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
        .stroke(isActive ? Color.statusFocus : Color.clear, style: .init(lineWidth: 2))
        .frame(height: 58)
        .background(Color.gray90)
        .cornerRadius(16)
        .overlay {
          HStack {
            Text(content)
              .pretendardCustomFont(textStyle: .body1NormalMedium)
              .foregroundStyle(Color.grayWhite)
            
            Spacer()
            
            Image(asset: isActive ? .activeSelectPart : .disableSelectPart)
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
