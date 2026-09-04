//
//  MemberMainSkeletonView.swift
//  Member
//
//  Created by DDD on 9/4/26.
//

import SwiftUI

import DDDDesignKit

public struct MemberMainSkeletonView: View {
  public init() {}

  public var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      navigationSkeleton

      ScrollView {
        VStack(alignment: .leading, spacing: 56) {
          attendanceSkeleton
          scheduleSkeleton
        }
        .padding(.horizontal, 24)
      }
      .scrollIndicators(.hidden)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(.backGroundPrimary)
  }

  private var navigationSkeleton: some View {
    HStack(spacing: 12) {
      SkeletonView(.round(cornerRadius: 8))
        .frame(width: 112, height: 28)

      Spacer()

      SkeletonView(.circle)
        .frame(width: 36, height: 36)

      SkeletonView(.circle)
        .frame(width: 36, height: 36)
    }
    .frame(height: 52)
    .padding(.horizontal, 24)
  }

  private var attendanceSkeleton: some View {
    VStack(alignment: .leading, spacing: 16) {
      SkeletonView(.round(cornerRadius: 8))
        .frame(width: 210, height: 34)

      VStack(alignment: .leading, spacing: 8) {
        SkeletonView(.round(cornerRadius: 6))
          .frame(width: 190, height: 18)

        SkeletonView(.round(cornerRadius: 20))
          .frame(maxWidth: .infinity)
          .frame(height: 156)
      }
    }
    .padding(.top, 20)
  }

  private var scheduleSkeleton: some View {
    VStack(alignment: .leading, spacing: 16) {
      SkeletonView(.round(cornerRadius: 8))
        .frame(width: 150, height: 29)

      VStack(spacing: 12) {
        ForEach(0..<3, id: \.self) { _ in
          SkeletonView(.round(cornerRadius: 16))
            .frame(maxWidth: .infinity)
            .frame(height: 92)
        }
      }
    }
  }
}

#Preview {
  MemberMainSkeletonView()
}
