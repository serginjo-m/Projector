//
//  CameraNote.swift
//  Projector
//
//  Created by Serginjo Melnik on 18.04.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class CameraNote: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    //Event title
    @objc dynamic var title: String?
    
    // Date represents a given day in a month.
    @objc dynamic var date = Date()
    
    //becouse Realm is not support UIImages type
    @objc dynamic var picture: String = ""
    
    //MARK: Methods
    override static func primaryKey() -> String {
        return "id"
    }
}
