//
//  ProgressShape.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

//Progress shape
class ProgressShapeLayer: CAShapeLayer {
    override init(layer: Any) {
        super.init(layer: layer)
    }
    //animation logic
    var shapeDisplayLink: AnimationDisplayLink?
    
    init(strokeColor: CGColor, arcCenter: CGPoint, strokeEnd: CGFloat, startValue: Double, actualValue:Double, animationDuration: Double) {
        super.init()
        self.path = UIBezierPath(arcCenter: arcCenter, radius: 60 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        self.strokeColor = strokeColor
        self.lineWidth = 12
        self.lineCap = CAShapeLayerLineCap.round
        //rotate layer
        self.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        self.fillColor = UIColor.clear.cgColor
        self.strokeEnd = strokeEnd
        
        self.shapeDisplayLink = AnimationDisplayLink(label: nil, shape: self, startValue: startValue, actualValue: actualValue, animationDuration: animationDuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
