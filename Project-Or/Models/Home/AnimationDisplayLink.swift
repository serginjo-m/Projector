//
//  AnimationDisplayLink.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class AnimationDisplayLink: NSObject{
    var displayLink: CADisplayLink?
    let label: UILabel?
    let shape: CAShapeLayer?
    var animationStartDate = Date()
    let startValue: Double
    var actualValue: Double
    let animationDuration: Double
    var units: String?
    
    init(label: UILabel?, shape: CAShapeLayer?, startValue: Double, actualValue: Double, animationDuration: Double, units: String?) {
        
        self.startValue = startValue
        self.actualValue = actualValue
        self.animationDuration = animationDuration
        self.units = units
        
        self.label = label
        self.shape = shape
        super.init()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc func handleUpdate(){
        let unitsString = units ?? ""
        let now = Date()
        let elapseTime = now.timeIntervalSince(animationStartDate)
        if elapseTime > animationDuration {
            label?.text = "\(Int(actualValue))\(unitsString)"
            shape?.strokeEnd = CGFloat(actualValue / 100)
        }else{
            let percentageOfDuration = elapseTime / animationDuration
            let value = startValue + round(percentageOfDuration * (actualValue - startValue))
            label?.text = "\(Int(value))\(unitsString)"
            shape?.strokeEnd = CGFloat(value / 100)
        }
    }
    
}

