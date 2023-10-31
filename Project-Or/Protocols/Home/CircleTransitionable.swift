//
//  CircleTransitionable.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

//protocol defines the information I’ll need from each view controller in order to successfully animate things
protocol CircleTransitionable{
    var profileConfigurationButton: UIButton {get}//trigger button
    var contentTextView: UITextView {get}//text to animate
    var mainView: UIView {get}//whole view controller shapshot that will be animated
}
