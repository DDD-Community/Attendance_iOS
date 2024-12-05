//
//  SignUpPartText.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/3/24.
//

import SwiftUI

public struct SignUpPartText: View {
  var content: String
  var title: String
  var subtitle: String
  
  public init(
    content: String,
    title: String,
    subtitle: String
  ) {
    self.content = content
    self.title = title
    self.subtitle = subtitle
  }
  
  
  public var body: some View {
        VStack(alignment: .center) {
            Spacer()
                .frame(height: 40)
            
            Text(content)
                .pretendardCustomFont(textStyle: .tilte1NormalBold)
                .foregroundStyle(.staticWhite)
            
            Spacer()
                .frame(height: 8)
            
          Text(title)
                .pretendardCustomFont(textStyle: .body3NormalMedium)
                .foregroundStyle(.staticWhite)
          
          if !subtitle.isEmpty {
            Text(subtitle)
                  .pretendardCustomFont(textStyle: .body3NormalMedium)
                  .foregroundStyle(.staticWhite)
          }
        }
    }
}
