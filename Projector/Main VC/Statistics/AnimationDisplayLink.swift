//
//  AnimationDisplayLink.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

// logic for animation
class AnimationDisplayLink: NSObject{
    //timer object that refresh 60 time a second
    var displayLink: CADisplayLink?
    //two objects for calculation, label of shape
    let label: UILabel?
    let shape: CAShapeLayer?
    
    //start point for animation
    var animationStartDate = Date()
    //value starts by
    let startValue: Double
    //value ends by
    var actualValue: Double
    //animation duration
    let animationDuration: Double
    
    init(label: UILabel?, shape: CAShapeLayer?, startValue: Double, actualValue: Double, animationDuration: Double) {
        
        self.startValue = startValue
        self.actualValue = actualValue
        self.animationDuration = animationDuration
        
        self.label = label
        self.shape = shape
        
        // ! declare before super.init
        super.init()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc func handleUpdate(){
        
        //every refresh it would be defined again
        let now = Date()
        //difference bwn start app time & every screen refresh
        let elapseTime = now.timeIntervalSince(animationStartDate)
        //when animation reaches end value
        if elapseTime > animationDuration {
            label?.text = "\(Int(actualValue))%"
            shape?.strokeEnd = CGFloat(actualValue / 100)
        }else{
            //percentage
            let percentageOfDuration = elapseTime / animationDuration
            let value = startValue + round(percentageOfDuration * (actualValue - startValue))
            label?.text = "\(Int(value))%"
            shape?.strokeEnd = CGFloat(value / 100)
        }
    }
    
}

