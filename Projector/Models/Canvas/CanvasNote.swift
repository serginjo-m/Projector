//
//  CanvasObject.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class CanvasNote: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    let list = List<CanvasLinesArray>()
    
    //MARK: Methods
    override static func primaryKey() -> String {
        return "id"
    }
}
