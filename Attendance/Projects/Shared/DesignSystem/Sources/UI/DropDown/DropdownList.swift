//
//  DropdownList.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 1/16/25.
//

import SwiftUI

public struct DropdownList: View {
  let items: [String]
  @Binding var selectedItem: String
  @Binding var isExpanded: Bool
  
  public init(
    items: [String],
    selectedItem: Binding<String>,
    isExpanded: Binding<Bool>
  ) {
    self.items = items
    self._selectedItem = selectedItem
    self._isExpanded = isExpanded
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      ForEach(items.indices, id: \.self) { index in
        VStack(spacing: 0) {
          Button(action: {
            withAnimation {
              selectedItem = items[index]
              isExpanded = false
            }
          }) {
            HStack {
              Text(items[index])
                .foregroundColor(selectedItem == items[index] ? .staticWhite : .borderInactive)
                .pretendardCustomFont(textStyle: .title3NormalBold)
                .padding()
              
              Spacer()
            }
            .background(.borderDisabled)
            .frame(width: 140)
          }
          
          // Divider 추가 (마지막 항목 제외)
          if index < items.count - 1 {
            Divider()
              .background(.borderInverse) // Divider 색상
          }
        }
      }
    }
    .cornerRadius(6)
  }
}
