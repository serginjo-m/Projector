//
//  SwipingPage.swift
//  Projector
//
//  Created by Serginjo Melnik on 23.09.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
struct SwipingPage {
    let imageName: String
    let headerString: String
    let bodyText: String
    let imageConstraints: SwipingImageConstraints
}

struct SwipingImageConstraints {
    let imageHeight: Double
    let imageCenterYAnchor: CGFloat
    let imageCenterXAnchor: CGFloat
}
