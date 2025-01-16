//
//  DropdownList.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 1/16/25.
//

import SwiftUI

public struct DropdownList: View {
  let items: [String]
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
          Button {
            withAnimation {
              // desc 값으로 SelectDropDownItem을 찾음
              if let matchedItem = SelectDropDownItem.allCases.first(where: { $0.desc == item }) {
                selectedItem = matchedItem
              }
              isExpanded = false
            }
          } label: {
            HStack {
              Text(item) // item은 이미 desc 값임
                .foregroundColor(selectedItem.desc == item ? .staticWhite : .borderInactive)
                .pretendardCustomFont(textStyle: .title3NormalBold)
                .padding()
              
              Spacer()
            }
            .background(.borderDisabled)
            .frame(width: 140)
          }
          
          // Divider 추가 (마지막 항목 제외)
          if item != items.last {
            Divider()
              .background(.borderInverse) // Divider 색상
          }
        }
      }
    }
    .background(Color.borderDisabled)
    .cornerRadius(6)
  }
}
