//
//  CountingLabel.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

//Label that perform counting animation
class CountingLabel: UILabel {
    
    //animation logic
    var labelDisplayLink: AnimationDisplayLink?
    
    init(startValue: Double, actualValue:Double, animationDuration: Double) {
        super.init(frame: .zero)
        self.text = "\(Int(startValue))%"
        self.textColor = UIColor.init(displayP3Red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        self.font = UIFont.boldSystemFont(ofSize: 29)
        self.textAlignment = .center
        //passing all data required for animation
        self.labelDisplayLink = AnimationDisplayLink(label: self, shape: nil, startValue: startValue, actualValue: actualValue, animationDuration: animationDuration)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
