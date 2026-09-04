//
//  MemberQRCodeSkeletonView.swift
//  Member
//
//  Created by DDD on 9/4/26.
//

import SwiftUI

import DDDDesignKit

public struct MemberQRCodeSkeletonView: View {
  public init() {}

  public var body: some View {
    SkeletonView(.round(cornerRadius: 24))
      .frame(width: 270, height: 270)
  }
}

#Preview {
  MemberQRCodeSkeletonView()
}
