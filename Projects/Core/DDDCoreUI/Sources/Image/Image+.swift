//
//  Image+.swift
//  DDDCoreUI
//
//  Created by 서원지 on 7/13/24.
//

import UIKit

public extension UIImage {
  func roundedImage() -> UIImage? {
    let imageSize = CGSize(width: self.size.width, height: self.size.height)
    let radius = min(self.size.width, self.size.height) / 2.0
    let roundedRect = CGRect(origin: .zero, size: imageSize).insetBy(dx: radius, dy: radius)
    
    let renderer = UIGraphicsImageRenderer(size: imageSize)
    let roundedImage = renderer.image { context in
      let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: imageSize), cornerRadius: radius)
      context.cgContext.addPath(path.cgPath)
      context.cgContext.clip()
      self.draw(in: roundedRect)
    }
    return roundedImage
  }
  
  func setRoundedCorners() -> UIImage? {
    // 이미지 크기와 코너 반경 직접 계산 (UIImageView 생성 불필요)
    let imageSize = self.size
    let cornerRadius = min(imageSize.width, imageSize.height) / 2.0

    // 현대적인 UIGraphicsImageRenderer 사용 (메모리 효율적)
    let renderer = UIGraphicsImageRenderer(size: imageSize)
    let roundedImage = renderer.image { context in
      // 코너 반경으로 클리핑 패스 생성
      let rect = CGRect(origin: .zero, size: imageSize)
      let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
      context.cgContext.addPath(path.cgPath)
      context.cgContext.clip()

      // 원본 이미지 그리기
      self.draw(in: rect)
    }

    return roundedImage
  }
}
