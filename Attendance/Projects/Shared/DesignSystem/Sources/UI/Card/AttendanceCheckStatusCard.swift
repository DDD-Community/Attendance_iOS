//
//  AttendanceCheckStatusCard.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 1/27/25.
//

import SwiftUI
import Model

public struct AttendanceCheckStatusCard: View {
  private let attandanceType: AttendanceType
  private let selectPart: SelectPart
  private let selectTeam: SelectTeam
  private let name: String
  
  public init(
    attandanceType: AttendanceType,
    selectPart: SelectPart,
    selectTeam: SelectTeam,
    name: String
  ) {
    self.attandanceType = attandanceType
    self.selectPart = selectPart
    self.selectTeam = selectTeam
    self.name = name
  }
  
  public var body: some View {
    VStack {
      VStack(spacing: .zero) {
        Spacer()
          .frame(height: 16)
        
        HStack {
          VStack(alignment: .leading, spacing: .zero) {
            HStack {
              Text(name)
                .pretendardCustomFont(textStyle: .title3NormalBold)
                .foregroundStyle(.staticWhite)
              Spacer()
            }
            
            Text("\(selectTeam.attandanceCardDesc) / \(selectPart.attendanceListDesc) ")
              .pretendardCustomFont(textStyle: .body2NormalBold)
              .foregroundStyle(.staticWhite)
          }
          
          Spacer()
          
          HStack(spacing: .zero) {
            Text(attandanceType.koreanDesc)
              .pretendardCustomFont(textStyle: .body2NormalMedium)
              .foregroundStyle(.staticWhite)
            
            Spacer()
              .frame(width: 12)
            
            Image(assetName: attandanceType.imageDesc)
              .resizable()
              .scaledToFit()
              .frame(width: 24, height: 24)
          }
          
        }
        
        
        Spacer()
          .frame(height: 16)
      }
      .padding(.horizontal, 20)
    }
    .background(.borderInverse)
    .frame(height: 84)
    .cornerRadius(15)
  }
}
