//
//  ButtonExtension.swift
//  Projector
//
//  Created by Serginjo Melnik on 10/10/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit

extension UIButton {
  func setBackgroundColor(_ color: UIColor, forState controlState: UIControl.State) {
    let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
      color.setFill()
      UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
    }
    setBackgroundImage(colorImage, for: controlState)
  }
}
