//
//  CameraNote.swift
//  Projector
//
//  Created by Serginjo Melnik on 18.04.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class TextNote: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    //TextNote text
    @objc dynamic var text = ""
    
    //text block height
    @objc dynamic var height = 0
    
    //MARK: Methods
    override static func primaryKey() -> String {
        return "id"
    }
}
