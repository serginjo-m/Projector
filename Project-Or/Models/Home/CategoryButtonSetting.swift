//
//  CategoryButtonSetting.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class CategoryButtonSetting: NSObject{
    let imageName: String
    let cellColor: UIColor
    let buttonTitle: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let imageTopAnchor: CGFloat
    let imageLeftAnchor: CGFloat
    let titleLeftAnchor: CGFloat
    
    init(imageName: String, cellColor: UIColor, buttonTitle: String, imageWidth: CGFloat, imageHeight: CGFloat, imageTopAnchor: CGFloat, imageLeftAnchor: CGFloat, titleLeftAnchor: CGFloat){
        self.imageName = imageName
        self.cellColor = cellColor
        self.buttonTitle = buttonTitle
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.imageTopAnchor = imageTopAnchor
        self.imageLeftAnchor = imageLeftAnchor
        self.titleLeftAnchor = titleLeftAnchor
    }
}
