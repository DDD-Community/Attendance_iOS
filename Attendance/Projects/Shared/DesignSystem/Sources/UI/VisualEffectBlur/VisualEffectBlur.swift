//
//  VisualEffectBlur.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 4/6/25.
//

import SwiftUI
import UIKit

public struct VisualEffectBlur: UIViewRepresentable {
  private var blurStyle: UIBlurEffect.Style

  public init(
    blurStyle: UIBlurEffect.Style
  ) {
    self.blurStyle = blurStyle
  }
  
  public func makeUIView(context: Context) -> UIVisualEffectView {
    return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
  }

  public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: blurStyle)
  }
}
