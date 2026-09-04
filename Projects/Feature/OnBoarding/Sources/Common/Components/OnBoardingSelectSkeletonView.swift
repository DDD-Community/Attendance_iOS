//
//  OnBoardingSelectSkeletonView.swift
//  OnBoarding
//
//  Created by DDD on 9/4/26.
//

import DDDCoreUI
import SwiftUI

import DDDDesignKit

/// 온보딩 선택 화면들이 목록을 불러오는 동안 제목과 목록 자리를 대신 채운다.
/// `SignUpPartText` / `SelectPartItem` / `SelectTeamIteam` 과 높이·여백을 맞춰서
/// 로딩이 끝나도 콘텐츠가 제자리에서 그대로 바뀌게 한다.
struct OnBoardingSelectSkeletonView: View {
  private let rowCount: Int

  init(rowCount: Int = 6) {
    self.rowCount = rowCount
  }

  var body: some View {
    VStack {
      titleSkeleton

      listSkeleton
    }
  }
}

extension OnBoardingSelectSkeletonView {
  private var titleSkeleton: some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 40)

      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 220, height: 28)

      Spacer()
        .frame(height: 8)

      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 260, height: 14)
    }
  }

  private var listSkeleton: some View {
    VStack {
      Spacer()
        .frame(height: 40)

      VStack {
        ForEach(0 ..< rowCount, id: \.self) { _ in
          SkeletonView(.round(cornerRadius: 16))
            .frame(height: 58)
            .padding(.horizontal, 24)
        }

        Spacer()
      }
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }
}

#Preview {
  ZStack {
    Color.backGroundPrimary
      .edgesIgnoringSafeArea(.all)

    OnBoardingSelectSkeletonView()
  }
}
