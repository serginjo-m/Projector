//
//  SingleLineObject.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class SingleLineObject: Object {
    var color = 0
    var strokeWidth: Float = 0
    var singleLine = List<LineCGPoint>()
}
