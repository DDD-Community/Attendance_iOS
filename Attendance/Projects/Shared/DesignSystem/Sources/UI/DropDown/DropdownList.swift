//
//  DropdownList.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 1/16/25.
//

import SwiftUI

public struct DropdownList: View {
  private let items: [String]
  @Binding var selectedItem: SelectDropDownItem
  @Binding var isExpanded: Bool
  
  public init(
    items: [String],
    selectedItem: Binding<SelectDropDownItem>,
    isExpanded: Binding<Bool>
  ) {
    self.items = items
    self._selectedItem = selectedItem
    self._isExpanded = isExpanded
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      ForEach(items, id: \.self) { item in
        VStack(spacing: 0) {
          HStack {
            Text(item) // item은 이미 desc 값임
              .foregroundColor(selectedItem.desc == item ? .staticWhite : .borderInactive)
              .pretendardCustomFont(textStyle: .title3NormalBold)
              .padding()
            
            Spacer()
          }
          .onTapGesture {
            withAnimation {
              if let matchedItem = SelectDropDownItem.allCases.first(where: { $0.desc == item }) {
                selectedItem = matchedItem
              }
              isExpanded = false
            }
          }
          .background(.borderDisabled)
          .frame(width: 140)
          
          // Divider 추가 (마지막 항목 제외)
          if item != items.last {
            Divider()
              .background(.borderInverse) // Divider 색상
          }
        }
      }
    }
    .background(.borderDisabled)
    .cornerRadius(12)
  }
}
