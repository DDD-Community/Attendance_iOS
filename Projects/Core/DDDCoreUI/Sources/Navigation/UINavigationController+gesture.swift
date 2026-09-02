//
//  UINavigationController+gesture.swift
//  DDDCoreUI
//
//  Created by DDD on 7/20/24.
//

import UIKit

extension UINavigationController: UIKit.UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    interactivePopGestureRecognizer?.delegate = self
  }
  
  public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
    return canBeginInteractivePopGesture
  }

  /// 루트 화면에서는 interactive pop을 막고, 이전 화면이 있을 때만 허용합니다.
  var canBeginInteractivePopGesture: Bool {
    return viewControllers.count > 1
  }
}
