//
//  GradientView.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
//MARK: Gradient
//gradient inside view so it can use constraints
class GradientView: UIView {
    
    private let gradient : CAGradientLayer = CAGradientLayer()
    private let gradientStartColor: UIColor
    private let gradientMiddleColor: UIColor
    private let gradientEndColor: UIColor
    
    init(gradientStartColor: UIColor, gradientMiddleColor: UIColor, gradientEndColor: UIColor) {
        self.gradientStartColor = gradientStartColor
        self.gradientMiddleColor = gradientMiddleColor
        self.gradientEndColor = gradientEndColor
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = self.bounds
        gradient.locations = [0.0, 0.3, 0.6]
    }
    
    override public func draw(_ rect: CGRect) {
        gradient.frame = self.bounds
        gradient.colors = [gradientEndColor.cgColor, gradientMiddleColor.cgColor, gradientStartColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        }
    }
}
