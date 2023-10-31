//
//  RecentActivitiesCV.swift
//  Projector
//
//  Created by Serginjo Melnik on 31.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class NumberCellSetting: NSObject{
    let imageName: String
    let cellColor: UIColor
    let buttonTitle: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let imageTopAnchor: CGFloat
    let imageLeftAnchor: CGFloat
    
    init(imageName: String, cellColor: UIColor, buttonTitle: String, imageWidth: CGFloat, imageHeight: CGFloat, imageTopAnchor: CGFloat, imageLeftAnchor: CGFloat){
        self.imageName = imageName
        self.cellColor = cellColor
        self.buttonTitle = buttonTitle
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.imageTopAnchor = imageTopAnchor
        self.imageLeftAnchor = imageLeftAnchor
    }
}
