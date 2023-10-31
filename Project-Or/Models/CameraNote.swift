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
    @objc dynamic var title: String?
    @objc dynamic var date = Date()
    @objc dynamic var picture: String = ""
    @objc dynamic var height = 0
    @objc dynamic var width = 0
    
    override static func primaryKey() -> String {
        return "id"
    }
}
