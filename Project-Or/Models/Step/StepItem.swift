//
//  StepItem.swift
//  Projector
//
//  Created by Serginjo Melnik on 06/11/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StepItem: Object {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var text = ""
    @objc dynamic var title = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
}

