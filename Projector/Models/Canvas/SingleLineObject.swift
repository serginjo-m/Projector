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
    @objc dynamic var color = 0
    @objc dynamic var strokeWidth: Float = 0
    let singleLine = List<LineCGPoint>()
}
